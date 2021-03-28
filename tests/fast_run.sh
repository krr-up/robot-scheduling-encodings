#!/usr/bin/env bash


BASE="fast_dl_encoding"
INSTANCE="instance1.lp"
#INSTANCE="sat1.lp"
#INSTANCE="unsat1.lp"
#ASP="../encodings/task_sequencing.lp ../encodings/${BASE}.lp ${INSTANCE}"
ASP="../encodings/${BASE}.lp instances/${INSTANCE}"

CLINGODLFACTS="../scripts/clingo-dl-facts.sh"
CLINGOFACTS="../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"

# To pretty print the output
#${CLINGODLFACTS} "${ASP}" | ${CLINGOFACTS} "${BASE}_user_output.lp" -

# To check the solution - make sure the plan is collision free
${CLINGODLFACTS} "${ASP}" | ${CLINGOFACTS} "${BASE}_walk_output.lp" -
${CLINGODLFACTS} "${ASP}" | ${CLINGOFACTS}  "${BASE}_walk_output.lp" - | clingo "instances/${INSTANCE}" solution_checker.lp -

