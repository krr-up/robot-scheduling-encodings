#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

VARIANT="basic"
MAXSTEP=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    key=$1

    case $key in
        -h)
            echo "usage: $0 [-h] [-m <n> ] [-v <variant>]"
            exit 1
            ;;
        -m)
            MAXSTEP="-c maxstep=$2"
            shift ; shift
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

if [ "$MAXSTEP" == "" ]; then
    MAXSTEP="-c maxstep=30"
fi

BASE="walk_encoding"
VARIANT="basic"
ASP="${THIS_DIR}/../encodings/${BASE}_${VARIANT}.lp"

CLINGODLFACTS="${THIS_DIR}/../scripts/clingo-dl-facts.sh"
CLINGOFACTS="${THIS_DIR}/../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"
CLINGO="clingo --verbose=0 --quiet=2,2,2 --out-atomf="%s.""

echo "Running clingo-dl ${MAXSTEP} ${ASP} $@ "
echo ""

# To just solve
#${CLINGODL} ${MAXSTEP} ${ASP} $@
#${CLINGODLFACTS} ${MAXSTEP} ${ASP} $@

# To pretty print the output
#${CLINGODLFACTS} ${MAXSTEP} ${ASP}  $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_debug.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} ${MAXSTEP} ${ASP}  $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" -

#${CLINGODLFACTS} ${MAXSTEP} ${ASP} $@ | ${CLINGOFACTS}  "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/solution_checker.lp -

${CLINGODLFACTS} ${MAXSTEP} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/user_output.lp ${THIS_DIR}/solution_checker.lp -



