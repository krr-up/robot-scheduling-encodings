#!/usr/bin/env bash

#-----------------------------------------------------------------------------
# The benchmark tool generates a directory for each solver configuration
# containing sub-directories with names that identify instances and contain
# clingo output. Read the files and turn the model into a walk encoding.
# ----------------------------------------------------------------------------

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"

CLINGOFACTS="${THIS_DIR}/clingo-facts.sh"

getmodelbasic(){
    output=$(${THIS_DIR}/extract_model.py --id -1 --rawonerror --count --fregex makespan --fregex replacement_ - --exec "${CLINGOFACTS} ${ASPSTATS} -")
    echo "$output"
}

getfwalkb(){
    local raw=$1
    output=$(extract_model.py --id -1 $raw |  ${CLINGOFACTS} "${TESTS_DIR}/paths_to_walk.lp" -)
    echo "$output"
}

getfwalk(){
    local raw=$1
    output=$(extract_model.py --id -1 $raw ${CLINGOFACTS} "${TESTS_DIR}/to_walk_experimental.lp" -)
    echo "$output"
}

getfwalk $1

#for instname in *.lp; do
#    rs="${instname}/run1/runsolver.solver"
#    getfwalk $rs
#done
