#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

VARIANT="basic"
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

BASE="fast_encoding"
ASP="${THIS_DIR}/../encodings/${BASE}_${VARIANT}.lp"

CLINGODLFACTS="${THIS_DIR}/../scripts/clingo-dl-facts.sh"
CLINGOFACTS="${THIS_DIR}/../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"

echo "Running clingo-dl ${ASP} $@ "
echo ""

# To just solve
#${CLINGODL} ${ASP} $@
#${CLINGODLFACTS} ${ASP} $@

# To pretty print the output
#${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_debug.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" -

#${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS}  "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/solution_checker.lp -

${CLINGODLFACTS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/user_output.lp ${THIS_DIR}/solution_checker.lp -


