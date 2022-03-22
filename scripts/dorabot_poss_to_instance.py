#!/usr/bin/env python3

"""Program to convert OSM maps to ASP graph facts."""

import argparse
import logging
import random
import sys
import networkx as nx
import networkx.algorithms as nxa

from clorm import Predicate, IntegerField, ConstantField, \
    refine_field, parse_fact_files, FactBase, in_

# Module level logger
logging.basicConfig()
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

class Conflict(Predicate):
    n1 = IntegerField
    n2 = IntegerField
    class Meta:
        name = "conflict"



UNIFIER = (PossHome, PossManipulator, PossEmptyPallet, PossStorage,
           Edge, Conflict)

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
    parser.add_argument('-t', '--tasks', dest='num_tasks',
                        type=int, required=True,
                        help="The number of randomly generated tasks")
    parser.add_argument('-et', '--excess_tasks', dest='excess_tasks',
                        action='store_true',
                        help=("If there are more tasks than manipulators "
                              "then use storage locations for the excess"))
    parser.add_argument('-l', '--log-level', default='info',
                        help=('Log level [fatal|error|info|warning|debug]'))

    return parser.parse_args()

# ------------------------------------------------------------------------------
# Remove nodes that are not reachable from some robot home. Builds a graph and
# then filters it.
# ------------------------------------------------------------------------------


def filter_nodes(fb, reachable_from):
    """Remove unreachable nodes."""
    G = nx.DiGraph()
    G.add_edges_from(list(fb.query(Edge).select(Edge.nfrom, Edge.nto).all()))
    g_logger.info(f"Robot nodes: {reachable_from}")

    bad_nodes = set()
    for connected_nodes in nxa.strongly_connected_components(G):
        if connected_nodes.isdisjoint(reachable_from):
            bad_nodes.update(connected_nodes)
            g_logger.info(("No Robots connected to sub-graph with "
                           f"{len(connected_nodes)} nodes"))
        else:
            g_logger.info(("Found robot reachable sub-graph with "
                           f"{len(connected_nodes)} nodes"))

    if not bad_nodes:
        return
    g_logger.info(f"Robot unreachable nodes: {bad_nodes}")

    # Remove any edge or conflict that includes a bad node
    bad_edges = fb.query(Edge).\
        where(in_(Edge.nfrom, bad_nodes) | in_(Edge.nto, bad_nodes))
    bad_vconflicts = fb.query(Conflict).\
        where(in_(Conflict.n1, bad_nodes) | in_(Conflict.n2, bad_nodes))

    edcount = bad_edges.delete()
    g_logger.debug(f"Deleted {edcount} edges")
    vccount = bad_vconflicts.delete()
    g_logger.debug(f"Deleted {vccount} node conflicts")


# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def choose_tasks(num_delivery_tasks, poss_manips,
                 poss_eps, poss_stores, excess_tasks):
    """Given the different cell locations, randomly generate num tasks."""
    if num_delivery_tasks <= 0:
        g_logger.fatal("No delivery tasks")
        raise RuntimeError("No delivery tasks")

    # The number of tasks may be more than the manipulators so we may have to
    # use storage locations or reduce the number of tasks depending on the
    # excess_tasks flag.
    manip_delivery_tasks = num_delivery_tasks
    excess_delivery_tasks = 0
    if num_delivery_tasks > len(poss_manips):
        msg = (f"More delivery tasks ({num_delivery_tasks}) than possible "
               f"manipulator robots ({len(poss_manips)})")
        g_logger.error(msg)
        if excess_tasks:
            excess_delivery_tasks = num_delivery_tasks - len(poss_manips)
            manip_delivery_tasks = len(poss_manips)
            g_logger.error((f"Using {excess_delivery_tasks} storage locations "
                            "as manipulator robot locations"))
        else:
            num_delivery_tasks = len(poss_manips)
            manip_delivery_tasks = num_delivery_tasks
            g_logger.error(f"Reducing delivery tasks to {num_delivery_tasks}")

    # Assign the pickup locations for the delivery tasks
    pickup_cells = []
    for c in random.sample(list(poss_manips), k=manip_delivery_tasks):
        pickup_cells.append(c)
        poss_eps.discard(c)
        poss_stores.discard(c)
    for c in random.sample(list(poss_stores), k=excess_delivery_tasks):
        pickup_cells.append(c)
        poss_eps.discard(c)
        poss_stores.discard(c)

    # Assign the putdown locations or the delivery tasks
    storage_cells = random.sample(list(poss_stores), k=num_delivery_tasks)
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
    for v in sorted(random.sample(list(poss_homes), k=num_robots)):
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
    g_logger.setLevel(level=args.log_level.upper())

    fb = parse_fact_files([args.in_file], unifier=UNIFIER, raise_nonfact=True)

    poss_homes = set(fb.query(PossHome).select(PossHome.node).all())
    poss_manips = set(fb.query(PossManipulator).
                      select(PossManipulator.node).all())
    poss_eps = set(fb.query(PossEmptyPallet).
                   select(PossEmptyPallet.node).all())
    poss_stores = set(fb.query(PossStorage).
                      select(PossStorage.node).all())

    g_logger.info(f"Poss home nodes: {len(poss_homes)}")
    g_logger.info(f"Poss manipulator nodes: {len(poss_manips)}")
    g_logger.info(f"Poss empty pallet nodes: {len(poss_eps)}")
    g_logger.info(f"Poss storage nodes: {len(poss_stores)}")
#
    num_robots = args.num_robots if args.num_robots else len(poss_homes)
    robot_strs, robot_nodes = choose_robots(num_robots, poss_homes)

#    orig_fb = FactBase(fb)
    out_fb = FactBase()
    filter_nodes(fb, robot_nodes)

    out_fb.add(fb.query(Edge).all())
    out_fb.add(fb.query(Conflict).all())

    #out_fb.add(fb.query(ConflictV).all())
    #out_fb.add(fb.query(ConflictE).all())

#    diff_fb = orig_fb - fb
#    print(f"Removed:\n{diff_fb.asp_str()}")
#    return
    task_strs = choose_tasks(args.num_tasks, poss_manips,
                             poss_eps, poss_stores, args.excess_tasks)
    # Write the output
    if args.out_file == "-":
        write_out(out_fb, robot_strs, task_strs, outfd=sys.stdout)
        return 0

    with open(args.out_file, 'w') as outfd:
        write_out(out_fb, robot_strs, task_strs, outfd=outfd)
    return 0

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    try:
        sys.exit(main())
    except ValueError as e:
        print(f"{e}", file=sys.stderr)
        sys.exit(1)

#    import cProfile, pstats
#    profiler = cProfile.Profile()
#    profiler.enable()
#    main()
#    profiler.disable()
#    stats = pstats.Stats(profiler).sort_stats('tottime')
#    stats.print_stats()
