#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"

#export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

CLINGOFACTS="${THIS_DIR}/clingo-facts.sh"
#${CLINGOFACTS} "${TESTS_DIR}/paths_to_walk.lp" $@

${CLINGOFACTS} "${TESTS_DIR}/paths_to_walk_fakeit.lp" $@ | ${CLINGOFACTS} "${TESTS_DIR}/paths_to_walk.lp" -
