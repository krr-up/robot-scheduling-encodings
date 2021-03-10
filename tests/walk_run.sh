#!/usr/bin/env bash


BASE="walk_dl_encoding"
INSTANCE="instance.lp"
#ASP="../encodings/task_sequencing.lp ../encodings/${BASE}.lp ${INSTANCE}"
ASP="../encodings/${BASE}.lp ${INSTANCE}"

CLINGO="clingo --verbose=0 --quiet=2,2,2 --out-atomf="%s.""

# To pretty print the output
clingo-dl-facts.sh "${ASP}" | clingo-facts.sh "${BASE}_user_output.lp" -

# To check the solution - make sure the plan is collision free
#clingo-dl-facts.sh "${ASP}" | clingo-facts.sh "${BASE}_walk_output.lp" -

clingo-dl-facts.sh "${ASP}" | clingo-facts.sh "${BASE}_walk_output.lp" - | clingo "${INSTANCE}" solution_checker.lp -


