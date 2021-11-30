#!/usr/bin/env python3

"""Program to convert OSM maps to ASP graph facts."""

import argparse
import logging
import sys
import subprocess
from pathlib import Path

# Module level logger
g_logger = logging.getLogger(__name__)


EXE_POSS_TO_INST = "dorabot_poss_to_instance.py"
EXE_SHORTEST_PATH = "shortest_paths.py"

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def parse_args():
    """Parse the command line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate concrete instances matching a specification")
    parser.add_argument('input',
                        help=("The input directory or file. A file is "
                              "expected to be an ASP graph generated from the "
                              "OSM data with the various possiblities for "
                              "robots, storage, empty pallets. If it is a "
                              "directory then each .lp file in the directory "
                              "is treated as a ASP graph file"))
    parser.add_argument('out_dir',
                        help=("The output directory for the resulting "
                              "instance files"))
    parser.add_argument('-r', '--robots', dest='num_robots',
                        type=int, default=None,
                        help=("The number of randomly generated robots "
                              "(default: as many as supported by the map)"))
    parser.add_argument('-t', '--tasks', dest='num_tasks', type=int, default=1,
                        help=("The number of randomly generated tasks "
                              "(default: 1)"))
    parser.add_argument('-i', '--instances', dest='num_instances', type=int,
                        default=1,
                        help=("The number of distinct instances to generate "
                              "(default: 1)"))

    return parser.parse_args()

# ------------------------------------------------------------------------------
# Given an input file that defines a graph and possible home, storage, empty
# pallet locations, create output instances matching a specification for the
# number of tasks. The files are written to a given output directory and some
# sub-directories are created.
# ------------------------------------------------------------------------------


def generate_instances(input_file, output_dir, num_tasks,
                       num_instances, num_robots=None):
    """Generate problem instances for a given input specification."""
    # There is an input file that must exist and then create multiple output
    # files.  Basic instance files will be put in a "basic" sub-directory while
    # files with shortest path information will be put in "sp".  Make the
    # appropriate output sub-directories if they don't exist

    basic_inst_dir = output_dir / "basic"
    sp_inst_dir = output_dir / "sp"

    if not input_file.is_file():
        print(f"Expected input file {input_file} doesn't exists",
              file=sys.stderr)
        return False

    print("========================================================")
    if num_robots is None:
        robots_str = "as many robots as possible"
    else:
        robots_str = "{num_robots} robots"
    print((f"Creating {num_instances} problem instances for {input_file} "
           f"with {num_tasks} tasks and {robots_str}."))

    basic_inst_dir.mkdir(parents=True, exist_ok=True)
    sp_inst_dir.mkdir(parents=True, exist_ok=True)
    stem = input_file.stem

    # Generate the appropriate number of instances
    for inst_id in range(1, num_instances+1):
        basic_inst = basic_inst_dir / f"{stem}_{inst_id}.lp"
        sp_inst = sp_inst_dir / f"{stem}_{inst_id}_sp.lp"

        # Make a basic instance file and if it succeeds make the corresponding
        # shortest path version
        run_pti = [EXE_POSS_TO_INST, "-t", f"{num_tasks}", "-et",
                   "-l", "warning", str(input_file), str(basic_inst)]
        run_sp = [EXE_SHORTEST_PATH, str(basic_inst), (str(sp_inst))]
        run_pti_str = " ".join(run_pti)
        run_sp_str = " ".join(run_sp)

        print(f"Running: {run_pti_str}", file=sys.stderr)
        result = subprocess.run(run_pti)
        if result.returncode != 0:
            print(f"Error executing: {run_pti_str}", file=sys.stderr)
            raise RuntimeError(f"Error executing: {run_pti_str}")
        print(f"Running: {run_sp_str}", file=sys.stderr)
        result = subprocess.run(run_sp)
        if result.returncode != 0:
            print(f"Error executing: {run_sp_str}", file=sys.stderr)
            raise RuntimeError(f"Error executing: {run_sp_str}")

    print("========================================================")

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------


def main():
    """Load the OSM file and generate many ASP instances."""
    args = parse_args()

    input = Path(args.input)
    out_dir = Path(args.out_dir)

    if input.is_file():
        generate_instances(input, out_dir, args.num_tasks,
                           args.num_instances, args.num_robots)
        return 0

    if not input.is_dir():
        print(f"{input} is not a directory")
        return 1

    # If it's a directory look for all XXX.lp files in the directory and create
    # corresponding sub-directories XXX in the output directory for each files
    # output instances

    for infile in input.glob('*.lp'):
        generate_instances(infile, out_dir, args.num_tasks,
                           args.num_instances, args.num_robots)

    return 0

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    main()
