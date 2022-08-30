#!/bin/bash
# http://www.cril.univ-artois.fr/~roussel/runsolver/

CAT="{run.root}/programs/gcat.sh"

cd "$(dirname $0)"

#top -n 1 -b > top.txt
#####
####
#### DPR 20220808 Added a "-d 30" for a 30s delay before SIGKILL is called - because the job was
#### being killed too quickly.
[[ -e .finished ]] || $CAT "{run.file}" | "{run.root}/programs/runsolver-3.4.0" \
    -M 20000 \
    -w runsolver.watcher \
    -o runsolver.solver \
    -W {run.timeout} \
    -d 30 \
    "{run.root}/programs/{run.solver}" {run.args}

touch .finished
