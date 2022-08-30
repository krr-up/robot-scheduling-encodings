#!/usr/bin/env python3

# Generate a set of "all_maxstep" files by looking through an input CSV file
# that match filenames to a maxstep value, then copying that appropriate file to
# the all_maxstep directory and append the maxstep value.

import sys
import shutil
import re
from pathlib import Path

#regex = re.compile(r'^(")?(([\,][\"])+)(")?\s*,\s*(\d+)')
regex = re.compile(r'^"?(?P<mname>([^",])+)"?,\s*(?P<maxstep>\d+)')

input_maxstep_file = Path("maxsteps.csv")
input_dirs = [Path("dorabot_coarse"), Path("dorabot_detailed"), Path("philipp")]
output_all_maxstep_dir = Path("all_maxstep")

def copy_and_append(infilename, maxstep, outfilename):
    print((f"\tInfilename: {infilename}, maxstep: {maxstep}, "
           f"outfilename: {outfilename}"))
    shutil.copy(infilename, outfilename)
    with open(outfilename, 'a') as newfile:
        newfile.write(f"\n#const maxstep={maxstep}.\n")


def find_map_file(name):
    for in_dir in input_dirs:
        infile = in_dir / name
        if infile.is_file():
            return in_dir, infile
    raise ValueError("Cannot find matching file for {name}")

def make_maxstep(name, maxstep):
    """Find the matching input file and generate the output."""

    in_dir, infilename = find_map_file(Path(name))

    out_dir = in_dir.parent / (str(in_dir.name) + "_maxstep")
    if not out_dir.is_dir():
        out_dir.mkdir()
#    outfilename = output_all_maxstep_dir / Path(name)
    outfilename = out_dir / Path(name)

    print(f"Maxing maxstep file {infilename}:  {maxstep}")
    copy_and_append(infilename, maxstep, outfilename)


with open(input_maxstep_file) as f:
    for line in f.readlines():
        result = regex.match(line)
        if not result:
            print(f"REGEX FAILED: {line}")
        else:
            mname = result['mname']
            maxstep = int(result['maxstep'])
#            print(f"'{line.strip()}' => {mname} => {maxstep}")

        make_maxstep(mname, maxstep)
