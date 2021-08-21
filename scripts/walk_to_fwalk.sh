#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"

#export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

CLINGODLFACTS="${THIS_DIR}/clingo-dl-facts.sh"
CLINGOFACTS="${THIS_DIR}/clingo-facts.sh"
CLINGODL="clingo-dl"

${CLINGOFACTS} "${TESTS_DIR}/walk_to_fwalk.lp $@"

