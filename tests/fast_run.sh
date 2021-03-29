#!/usr/bin/env bash

if [ "$1" != "" ]; then
    INSTANCE="$1"
else
    #INSTANCE="instance1.lp"
    INSTANCE="sat3.lp"
    #INSTANCE="unsat4.lp"
    INSTANCE="instances/${INSTANCE}"
fi


BASE="fast_dl_encoding"
ASP="../encodings/${BASE}.lp ${INSTANCE}"

CLINGODLFACTS="../scripts/clingo-dl-facts.sh"
CLINGOFACTS="../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"

# To pretty print the output
${CLINGODLFACTS} "${ASP}" | ${CLINGOFACTS} "${BASE}_user_output.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} "${ASP}" | ${CLINGOFACTS} "${BASE}_walk_output.lp" -
#${CLINGODLFACTS} "${ASP}" | ${CLINGOFACTS}  "${BASE}_walk_output.lp" - | clingo "${INSTANCE}" solution_checker.lp -

