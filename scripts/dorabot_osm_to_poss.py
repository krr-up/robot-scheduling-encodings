#!/usr/bin/env python3

"""Program to convert OSM maps to ASP graph facts."""

import argparse
import logging
import sys
import math
import networkx as nx
import networkx.algorithms as nxa
from osm_parser import parse

# Module level logger
logging.basicConfig()
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
    parser.add_argument('-w', '--robot-width', dest='robot_width',
                        type=float, default=0.0,
                        help="The width of the robots in meters [default: 0.0]")
    parser.add_argument('-c', '--charge-as-home', dest='charge_as_home',
                        action='store_true',
                        help=("Treat all 'charge' cells as allowable "
                              "robot home, increasing max robots"))
    parser.add_argument('-l', '--log-level', default='info',
                        help=('Log level [fatal|error|info|warning|debug]'))

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
    """Get the keys associated with a node."""
    keys = set()
    for n in G.nodes():
        nattr = G.nodes[n]['nattr']
        if nattr:
            g_logger.debug(f"Node {n}: {nattr}")
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
    """Remove nodes that are not reachable from some robot home."""
    bad_nodes = set()
    rcount = 0
    for connected_nodes in nxa.connected_components(G):
        if connected_nodes.isdisjoint(poss_homes):
            bad_nodes.update(connected_nodes)
            g_logger.info(("Found robot unreachable sub-graph with "
                           f"{len(connected_nodes)} nodes"))
        else:
            rcount += 1
            g_logger.info(("Found robot reachable sub-graph with "
                           f"{len(connected_nodes)} nodes"))

    if bad_nodes:
        G.remove_nodes_from(bad_nodes)
        g_logger.info(f"Removed robot unreachable nodes: {bad_nodes}")
    if rcount > 1:
        g_logger.info(("Expecting only 1 robot reachable subgraphs, "
                       f"but there are {len(rcount)}"))


# ------------------------------------------------------------------------------
# Calculate whether two nodes conflict
# ------------------------------------------------------------------------------

def vertices_conflict(v1,v2,robot_width):
    xdist = abs(v1[0]-v2[0])
    ydist = abs(v1[1]-v2[1])
    vdist = math.sqrt(xdist**2.0 + ydist**2.0)
    return vdist <= robot_width

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def print_graph(robot_speed, robot_width, G, outfd):
    """Export the graph as ASP facts."""
    rspeed_ms = robot_speed

    # Write out the x,y coordinates of each node
    get_x = nx.get_node_attributes(G, 'x')
    get_y = nx.get_node_attributes(G, 'y')
    for v in G.nodes:
        x = round(get_x[v] * 1000.0)
        y = round(get_y[v] * 1000.0)
        print(f"node({v},{x},{y}).", file=outfd)

    def conflict_e(x1, x2, x3, x4):
        fd = outfd
        print("conflict(e,({},{}),({},{})).".format(x1, x2, x3, x4), file=fd)

    # Output the edges of the graph
    for (n1, n2) in G.edges:
        meters = G.edges[n1, n2]['weight']
        tt_ms = meters/rspeed_ms
        tt_mms = round(tt_ms * 1000.0)

        print(f"edge({n1},{n2},{tt_mms}).", file=outfd)
        print(f"edge({n2},{n1},{tt_mms}).", file=outfd)
#        conflict_e(n1, n2, n1, n2)
#        conflict_e(n1, n2, n2, n1)
#        conflict_e(n2, n1, n1, n2)
#        conflict_e(n2, n1, n2, n1)

    # Output the vertex conflicts

    # Every node conflicts with itself
    for v in G.nodes():
        print("conflict({},{}).".format(v, v), file=outfd)

    # If the robot width is non-zero then calculate the conflicts between all nodes
    if robot_width > 0.1:
        for v1 in G.nodes():
            for v2 in G.nodes():
                if int(v1) >= int(v2):
#                    print(f"{v1} >= {v2}")
                    continue
#                print(f"{v1} < {v2}")
                if vertices_conflict((get_x[v1], get_y[v1]), (get_x[v2],get_y[v2]), robot_width):
#                    print(f"conflict: {v1} and {v2}")
                    print(f"conflict({v1},{v2}).", file=outfd)
                    print(f"conflict({v2},{v1}).", file=outfd)

# ------------------------------------------------------------------------------
# Write out
# ------------------------------------------------------------------------------

def write_out(robot_speed, robot_width,
              graph, grid, poss_homes, poss_manips,
              poss_eps, poss_stores, outfd):
    """Write the ASP file."""
    x = math.ceil(grid.x * 1000.0)
    y = math.ceil(grid.y * 1000.0)
    print(f"grid({x},{y}).", file=outfd)
    for ph in poss_homes:
        print(f"poss_home({ph}).", file=outfd)
    for pm in poss_manips:
        print(f"poss_manipulator({pm}).", file=outfd)
    for ep in poss_eps:
        print(f"poss_empty_pallet({ep}).", file=outfd)
    for st in poss_stores:
        print(f"poss_storage({st}).", file=outfd)
    print_graph(robot_speed, robot_width, graph, outfd)


# ------------------------------------------------------------------------------
# calculate_grid(G) - we need to recalculate the grid once we've removed unreachable nodes
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def main():
    """Load the OSM file and export it as ASP facts."""

    args = parse_args()
    g_logger.setLevel(level=args.log_level.upper())

    (G, grid) = parse(args.in_file)
    G = G.to_undirected()                 # Make the graph undirected

    # Tag keys and value keys
    tagkeys = node_tag_keys(G)
    tagvalues = node_tag_values(G)
    g_logger.debug(f"Node tag keys: {tagkeys}")
    g_logger.debug(f"Node tag values: {tagvalues}")

    home_values = set(["standby"])
    if args.charge_as_home:
        g_logger.info("Allowing 'charge' nodes as possible robot homes")
        home_values.add("charge")

    if "type" in tagkeys:
        is_poss_home = lambda a: a["type"] == "standby_cell"
        is_poss_manip = lambda a: a["type"] == "manipulation_buffer_cell"
        is_poss_ep = lambda a: a["type"] == "empty_pallet"
        is_poss_store = lambda a: a["type"] == "storage_cell"
        g_logger.info("Poss home identified by tag type: standby_cell")
        g_logger.info("Poss manipulator identified by tag type: manipulation_buffer_cell")
        g_logger.info("Poss empty pallet location identifed by tag type: empty_pallet")
        g_logger.info("Poss storage location identifed by tag type: storage_cell")
    else:
        if "func_types" in tagkeys:
            is_poss_home = lambda a: a.get("func_types","") in home_values
            g_logger.info(f"Poss home identifed by func_type: {home_values}")
        else:
            is_poss_home = lambda a: a.get("cell_type", "") in home_values
            g_logger.info(f"Poss home identifed by cell_type: {home_values}")

        is_poss_ep = lambda a: a.get("cell_type", "") == "storage"
        g_logger.info("Poss empty pallet location identifed by cell_type: storage")
        is_poss_store = lambda a: a.get("cell_type", "") == "storage"
        g_logger.info("Poss storage location identifed by cell_type: storage")

        if "brienne_buffer" in tagvalues:
            is_poss_manip = lambda a: a.get("cell_type", "") == "brienne_buffer"
            g_logger.info("Poss manipulator identifed by cell_type: brienne_buffer")
        else:
            is_poss_manip = lambda a: a.get("cell_type", "") == "storage"
            g_logger.info("Poss manipulator identifed by cell_type: storage")

    poss_homes = nodes_with(G, is_poss_home)
    filter_nodes(G, poss_homes)

    poss_manips = nodes_with(G, is_poss_manip)
    poss_eps = nodes_with(G, is_poss_ep)
    poss_stores = nodes_with(G, is_poss_store)

    g_logger.info(f"Poss home nodes: {len(poss_homes)}")
    g_logger.info(f"Poss manipulator nodes: {len(poss_manips)}")
    g_logger.info(f"Poss empty pallet nodes: {len(poss_eps)}")
    g_logger.info(f"Poss storage nodes: {len(poss_stores)}")

    # Write the output
    if args.out_file == "-":
        write_out(robot_speed=args.robot_speed, robot_width=args.robot_width,
                  graph=G, grid=grid,
                  poss_homes=poss_homes, poss_manips=poss_manips,
                  poss_eps=poss_eps, poss_stores=poss_stores,
                  outfd=sys.stdout)
        return

    with open(args.out_file, 'w') as outfd:
        write_out(robot_speed=args.robot_speed, robot_width=args.robot_width,
                  graph=G, grid=grid,
                  poss_homes=poss_homes, poss_manips=poss_manips,
                  poss_eps=poss_eps, poss_stores=poss_stores,
                  outfd=outfd)


# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    main()
