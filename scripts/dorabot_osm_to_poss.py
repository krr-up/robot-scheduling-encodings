#!/usr/bin/env python3

"""Program to convert OSM maps to ASP graph facts."""

import argparse
import logging
import sys
import networkx.algorithms as nxa
from osm_parser import parse

# Module level logger
g_logger = logging.getLogger(__name__)


# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

def parse_args():
    """Parse the command line arguments."""
    parser = argparse.ArgumentParser(description="OSM to ASP graph facts")
    parser.add_argument('in_file',
                        help="The input OSM file")
    parser.add_argument('out_file',
                        help="The output ASP file")
    parser.add_argument('-s', '--robot-speed', dest='robot_speed',
                        type=float, default=1.0,
                        help="The speed of the robots in m/s [default: 1.0]")
    return parser.parse_args()

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

def nodes_with(G, func):
    """Return nodes that satisfy func condition."""
    result = set()
    for n in G.nodes():
        nattr = G.nodes[n]['nattr']
        if not nattr:
            continue
        if func(nattr):
            result.add(n)
    return result

def node_tag_keys(G):
    keys = set()
    for n in G.nodes():
        nattr = G.nodes[n]['nattr']
        if nattr:
            print(f"Node {n}: {nattr}", file=sys.stderr)
        for k in nattr.keys():
            keys.add(k)
    return keys

def node_tag_values(G):
    values = set()
    for n in G.nodes():
        nattr = G.nodes[n]['nattr']
        for v in nattr.values():
            values.add(v)
    return values


# ------------------------------------------------------------------------------
# Remove nodes that are not reachable from some possible robot home.
# ------------------------------------------------------------------------------


def filter_nodes(G, poss_homes):

    bad_nodes = set()
    rcount = 0
    for connected_nodes in nxa.connected_components(G):
        if connected_nodes.isdisjoint(poss_homes):
            bad_nodes.update(connected_nodes)
            print(("Found robot unreachable sub-graph with "
                   f"{len(connected_nodes)} nodes"), file=sys.stderr)
        else:
            rcount += 1
            print(("Found robot reachable sub-graph with "
                   f"{len(connected_nodes)} nodes"), file=sys.stderr)

    if bad_nodes:
        G.remove_nodes_from(bad_nodes)
        print(f"Removed robot unreachable nodes: {bad_nodes}", file=sys.stderr)
    if rcount > 1:
        print(("Expecting only 1 robot reachable subgraphs, "
               f"but there are {len(rcount)}"), file=sys.stderr)

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def print_graph(robot_speed, G, outfd):
    """Export the graph as ASP facts."""
    rspeed_ms = robot_speed

    def conflict(x1, x2, x3, x4):
        fd = outfd
        print("conflict(e,({},{}),({},{})).".format(x1, x2, x3, x4), file=fd)

    # Output the edges of the graph
    for (n1, n2) in G.edges:
        meters = G.edges[n1, n2]['weight']
        tt_ms = meters/rspeed_ms
        tt_mms = round(tt_ms * 1000.0)

        print(f"edge({n1},{n2},{tt_mms}).", file=outfd)
        print(f"edge({n2},{n1},{tt_mms}).", file=outfd)
        conflict(n1, n2, n1, n2)
        conflict(n1, n2, n2, n1)
        conflict(n2, n1, n1, n2)
        conflict(n2, n1, n2, n1)

    # Output the vertex conflicts
    for v in G.nodes():
        print("conflict(v,{},{}).".format(v, v), file=outfd)


# ------------------------------------------------------------------------------
# Write out
# ------------------------------------------------------------------------------

def write_out(robot_speed, graph, grid, poss_homes, poss_manips,
              poss_eps, poss_stores, outfd):
    """Write the ASP file."""
    print(f"grid({grid.x},{grid.y}).", file=outfd)
    for ph in poss_homes:
        print(f"poss_home({ph}).", file=outfd)
    for pm in poss_manips:
        print(f"poss_manipulator({pm}).", file=outfd)
    for ep in poss_eps:
        print(f"poss_empty_pallet({ep}).", file=outfd)
    for st in poss_stores:
        print(f"poss_storage({st}).", file=outfd)
    print_graph(robot_speed, graph, outfd)

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def main():
    """Load the OSM file and export it as ASP facts."""

    args = parse_args()
    (G, grid) = parse(args.in_file)
    G = G.to_undirected()                 # Make the graph undirected

    # Tag keys and value keys
    tagkeys = node_tag_keys(G)
    tagvalues = node_tag_values(G)
    print(f"Node tag keys: {tagkeys}", file=sys.stderr)
    print(f"Node tag values: {tagvalues}", file=sys.stderr)

    home_values = set(["standby", "charge"])

    if "type" in tagkeys:
        is_poss_home = lambda a: a["type"] == "standby_cell"
        is_poss_manip = lambda a: a["type"] == "manipulation_buffer_cell"
        is_poss_ep = lambda a: a["type"] == "empty_pallet"
        is_poss_store = lambda a: a["type"] == "storage_cell"

    else:
        if "func_types" in tagkeys:
            is_poss_home = lambda a: a.get("func_types","") in home_values
        else:
            is_poss_home = lambda a: a.get("cell_type", "") in home_values

        is_poss_ep = lambda a: a.get("cell_type", "") == "storage"
        is_poss_store = lambda a: a.get("cell_type", "") == "storage"

        if "brienne_buffer" in tagvalues:
            is_poss_manip = lambda a: a.get("cell_type", "") == "brienne_buffer"
        else:
            is_poss_manip = lambda a: a.get("cell_type", "") == "storage"

    poss_homes = nodes_with(G, is_poss_home)
    filter_nodes(G, poss_homes)

    poss_manips = nodes_with(G, is_poss_manip)
    poss_eps = nodes_with(G, is_poss_ep)
    poss_stores = nodes_with(G, is_poss_store)

    print(f"POSS HOMES: {len(poss_homes)}", file=sys.stderr)
    print(f"POSS MANIPS: {len(poss_manips)}", file=sys.stderr)
    print(f"POSS EPS: {len(poss_eps)}", file=sys.stderr)
    print(f"POSS STORES: {len(poss_stores)}", file=sys.stderr)

    # Write the output
    if args.out_file == "-":
        write_out(robot_speed=args.robot_speed, graph=G, grid=grid,
                  poss_homes=poss_homes, poss_manips=poss_manips,
                  poss_eps=poss_eps, poss_stores=poss_stores,
                  outfd=sys.stdout)
        return

    with open(args.out_file, 'w') as outfd:
        write_out(robot_speed=args.robot_speed, graph=G, grid=grid,
                  poss_homes=poss_homes, poss_manips=poss_manips,
                  poss_eps=poss_eps, poss_stores=poss_stores,
                  outfd=outfd)


# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    main()
