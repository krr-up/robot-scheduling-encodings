#!/usr/bin/env bash

if [ "$1" != "" ]; then
    INSTANCE="$1"
    shift
else
    #INSTANCE="instance1.lp"
    INSTANCE="sat3.lp"
    #INSTANCE="unsat4.lp"
    INSTANCE="instances/${INSTANCE}"
fi

BASE="path_dl_encoding"
ASP="../encodings/${BASE}.lp ${INSTANCE}"

CLINGODLFACTS="../scripts/clingo-dl-facts.sh"
CLINGOFACTS="../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"

#Just run the solver
#${CLINGODL} ${ASP} $@
#${CLINGODLFACTS} ${ASP} $@

# To pretty print the output
#${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS} "${BASE}_user_output.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS} "${BASE}_walk_output.lp" -

#${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS} "${BASE}_walk_output.lp" - | ${CLINGOFACTS} "${INSTANCE}" user_output.lp solution_checker.lp -

${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS}  "${BASE}_walk_output.lp" - | ${CLINGOFACTS} "${INSTANCE}" solution_checker.lp -

