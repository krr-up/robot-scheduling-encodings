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

BASE="walk_dl_encoding"
ASP="../encodings/${BASE}.lp ${INSTANCE}"

CLINGODLFACTS="../scripts/clingo-dl-facts.sh"
CLINGOFACTS="../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"
CLINGO="clingo --verbose=0 --quiet=2,2,2 --out-atomf="%s.""

# To just solve
#${CLINGODL} ${ASP} $@
#${CLINGODLFACTS} ${ASP} $@

# To pretty print the output
${CLINGODLFACTS} ${ASP}  $@ | ${CLINGOFACTS} "${BASE}_user_output.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} ${ASP}  $@ | ${CLINGOFACTS} "${BASE}_walk_output.lp" -
#${CLINGODLFACTS} ${ASP}  $@ | ${CLINGOFACTS} "${BASE}_walk_output.lp" - | clingo "${INSTANCE}" solution_checker.lp -


