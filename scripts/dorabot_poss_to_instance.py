#!/usr/bin/env python3

"""Program to convert OSM maps to ASP graph facts."""

import argparse
import logging
import random
import sys
import networkx as nx
import networkx.algorithms as nxa

from clorm import Predicate, IntegerField, ConstantField, RawField, \
    refine_field, simple_predicate, parse_fact_files, FactBase, in_

# Module level logger
g_logger = logging.getLogger(__name__)

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

class PossHome(Predicate):
    node = IntegerField
    class Meta:
        name = "poss_home"

class PossManipulator(Predicate):
    node = IntegerField
    class Meta:
        name = "poss_manipulator"

class PossEmptyPallet(Predicate):
    node = IntegerField
    class Meta:
        name = "poss_empty_pallet"


class PossStorage(Predicate):
    node = IntegerField
    class Meta:
        name = "poss_storage"

class Edge(Predicate):
    nfrom = IntegerField
    nto = IntegerField
    dist = IntegerField
    class Meta:
        name = "edge"

class ConflictV(Predicate):
    v = refine_field(ConstantField, ["v"])
    n1 = IntegerField
    n2 = IntegerField
    class Meta:
        name = "conflict"

class ConflictE(Predicate):
    e = refine_field(ConstantField, ["e"])
    e1 = (IntegerField, IntegerField)
    e2 = (IntegerField, IntegerField)
    class Meta:
        name = "conflict"


UNIFIER = (PossHome, PossManipulator, PossEmptyPallet, PossStorage,
           Edge, ConflictV, ConflictE)

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def parse_args():
    """Parse the command line arguments."""
    parser = argparse.ArgumentParser(description="Generate concrete instance")
    parser.add_argument('in_file',
                        help="The input ASP graph possibles file")
    parser.add_argument('out_file',
                        help="The output ASP file")
    parser.add_argument('-r', '--robots', dest='num_robots', type=int,
                        help="The number of randomly generated robots")
    parser.add_argument('-t', '--tasks', dest='num_tasks', type=int, default=0,
                        help="The number of randomly generated tasks")

    return parser.parse_args()

# ------------------------------------------------------------------------------
# Remove nodes that are not reachable from some robot home. Builds a graph and
# then filters it.
# ------------------------------------------------------------------------------


def filter_nodes(fb, reachable_from):
    G = nx.DiGraph()
    G.add_edges_from(list(fb.query(Edge).select(Edge.nfrom, Edge.nto).all()))
    print(f"Robot nodes: {reachable_from}", file=sys.stderr)

    bad_nodes = set()
    for connected_nodes in nxa.strongly_connected_components(G):
        if connected_nodes.isdisjoint(reachable_from):
            bad_nodes.update(connected_nodes)
            print(("No Robots connected to sub-graph with "
                   f"{len(connected_nodes)} nodes"), file=sys.stderr)
        else:
            print(("Found robot reachable sub-graph with "
                   f"{len(connected_nodes)} nodes"), file=sys.stderr)

    if not bad_nodes:
        return
    print(f"Robot unreachable nodes: {bad_nodes}", file=sys.stderr)

    # Remove any edge or conflict that includes a bad node
    bad_edges = fb.query(Edge).\
        where(in_(Edge.nfrom, bad_nodes) | in_(Edge.nto, bad_nodes))
    bad_vconflicts = fb.query(ConflictV).\
        where(in_(ConflictV.n1, bad_nodes) | in_(ConflictV.n2, bad_nodes))
    bad_econflicts = fb.query(ConflictE).\
        where(in_(ConflictE.e1[0], bad_nodes) |
              in_(ConflictE.e1[1], bad_nodes) |
              in_(ConflictE.e2[0], bad_nodes) |
              in_(ConflictE.e2[0], bad_nodes))

    edcount = bad_edges.delete()
    print(f"Deleted {edcount} edges", file=sys.stderr)
    vccount = bad_vconflicts.delete()
    print(f"Deleted {vccount} node conflicts", file=sys.stderr)
    eccount = bad_econflicts.delete()
    print(f"Deleted {eccount} edge conflicts", file=sys.stderr)


# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def choose_tasks(num_delivery_tasks, poss_manips,
                 poss_eps, poss_stores):
    """Given the different cell locations, randomly generate num tasks."""
    if num_delivery_tasks <= 0:
        g_logger.fatal("No delivery tasks")
        raise RuntimeError("No delivery tasks")
    if num_delivery_tasks > len(poss_manips):
        msg = ("More delivery tasks ({}) than possible manipulator "
               "robots ({})").format(num_delivery_tasks, len(poss_manips))
        g_logger.fatal(msg)
        raise RuntimeError(msg)

    pickup_cells = random.choices(list(poss_manips), k=num_delivery_tasks)
    for c in pickup_cells:
        poss_eps.discard(c)
        poss_stores.discard(c)
    storage_cells = random.choices(list(poss_stores), k=num_delivery_tasks)
    for c in storage_cells:
        poss_eps.discard(c)
    pallet_cells = list(poss_eps)

    tasks = []
    depends = []
    for dtask in range(1, num_delivery_tasks+1):
        dpickup = "({},dpickup)".format(dtask)
        dputdown = "({},dputdown)".format(dtask)
        rpickup = "({},rpickup)".format(dtask)
        rputdown = "({},rputdown)".format(dtask)
        pickup_cell = pickup_cells.pop()
        tasks.append("task({},{}).".format(dpickup, pickup_cell))
        tasks.append("task({},{}).".format(dputdown, storage_cells.pop()))
        tasks.append("task({},{}).".format(rpickup,
                                           random.choice(pallet_cells)))
        tasks.append("task({},{}).".format(rputdown, pickup_cell))
        depends.append("depends(deliver,{},{}).".format(dpickup, dputdown))
        depends.append("depends(deliver,{},{}).".format(rpickup, rputdown))
        depends.append("depends(wait,{},{}).".format(dpickup, rputdown))

    return tasks + depends

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def choose_robots(num_robots, poss_homes):
    """Given the possible robot homes randomly generate num robots."""
    if num_robots > len(poss_homes):
        msg = "More robots ({}) than possible home locations ({})".format(
            num_robots, len(poss_homes))
        g_logger.fatal(msg)
        raise RuntimeError(msg)
    rc = 1
    fact_strs = []
    nodes = []
    for v in random.choices(list(poss_homes), k=num_robots):
        nodes.append(v)
        r = "r{}".format(rc)
        rc += 1
        f1 = "robot({}).".format(r)
        f2 = "home({},{}).".format(r, v)
        f3 = "start({},{}).".format(r, v)
        fact_strs.append("{}   {}   {}".format(f1, f2, f3))
    return (fact_strs, nodes)

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Write out
# ------------------------------------------------------------------------------


def write_out(fbout, robots, tasks, outfd):
    """Write the ASP file."""
    for r in robots:
        print(r, file=outfd)
    for t in tasks:
        print(t, file=outfd)
    print(f"\n{fbout.asp_str()}", file=outfd)

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def main():
    """Load the OSM file and export it as ASP facts."""

    args = parse_args()
    fb = parse_fact_files([args.in_file], unifier=UNIFIER, raise_nonfact=True)

    poss_homes = set(fb.query(PossHome).select(PossHome.node).all())
    poss_manips = set(fb.query(PossManipulator).
                      select(PossManipulator.node).all())
    poss_eps = set(fb.query(PossEmptyPallet).
                   select(PossEmptyPallet.node).all())
    poss_stores = set(fb.query(PossStorage).
                      select(PossStorage.node).all())

    print(f"POSS HOMES: {len(poss_homes)}", file=sys.stderr)
    print(f"POSS MANIPS: {len(poss_manips)}", file=sys.stderr)
    print(f"POSS EPS: {len(poss_eps)}", file=sys.stderr)
    print(f"POSS STORES: {len(poss_stores)}", file=sys.stderr)

    num_robots = args.num_robots if args.num_robots else len(poss_homes)
    robot_strs, robot_nodes = choose_robots(num_robots, poss_homes)

#    orig_fb = FactBase(fb)
    out_fb = FactBase()
    filter_nodes(fb, robot_nodes)
    out_fb.add(fb.query(Edge).all())
    out_fb.add(fb.query(ConflictV).all())
    out_fb.add(fb.query(ConflictE).all())

#    diff_fb = orig_fb - fb
#    print(f"Removed:\n{diff_fb.asp_str()}")
#    return
    task_strs = choose_tasks(args.num_tasks, poss_manips,
                             poss_eps, poss_stores)
    # Write the output
    if args.out_file == "-":
        write_out(out_fb, robot_strs, task_strs, outfd=sys.stdout)
        return

    with open(args.out_file, 'w') as outfd:
        write_out(out_fb, robot_strs, task_strs, outfd=outfd)


# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    main()
