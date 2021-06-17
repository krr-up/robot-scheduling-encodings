#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

CLINGOFACTS="${THIS_DIR}/../scripts/clingo-facts.sh"
${CLINGOFACTS} "${THIS_DIR}/to_paths.lp" $@
