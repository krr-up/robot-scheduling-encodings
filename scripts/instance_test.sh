#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"

usage(){
    echo "usage: $0 <instance>"
    exit 1
}

if [ "$1" == "" ]; then
    usage
fi

ASP="${TESTS_DIR}/instance_checker.lp"

CLINGOFACTS="${THIS_DIR}/clingo-facts.sh"
CLINGO="clingo"

>&2 echo "Executing: clingo ${OPTIONS} ${ASP} $@ "
>&2 echo ""

#Just run the solver
${CLINGOFACTS} ${ASP} $@
