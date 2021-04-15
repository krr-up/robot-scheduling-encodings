#!/usr/bin/env bash

VARIANT="basic"
OPTIONS=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    key=$1

    case $key in
        -h)
            echo "usage: $0 [-h] [-v <variant>]"
            exit 1
            ;;
        -v)
            VARIANT="$2"
            shift ; shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional arguments

BASE="walk_encoding"
VARIANT="basic"
ASP="../encodings/${BASE}_${VARIANT}.lp"

CLINGODLFACTS="../scripts/clingo-dl-facts.sh"
CLINGOFACTS="../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"
CLINGO="clingo --verbose=0 --quiet=2,2,2 --out-atomf="%s.""

# To just solve
#${CLINGODL} ${ASP} $@
#${CLINGODLFACTS} ${ASP} $@

# To pretty print the output
#${CLINGODLFACTS} ${ASP}  $@ | ${CLINGOFACTS} "${BASE}_debug.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} ${ASP}  $@ | ${CLINGOFACTS} "${BASE}_to_plan.lp" -

#${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS}  "${BASE}_to_plan.lp" - | ${CLINGOFACTS} solution_checker.lp -

${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS} "${BASE}_to_plan.lp" - | ${CLINGOFACTS} user_output.lp solution_checker.lp -



