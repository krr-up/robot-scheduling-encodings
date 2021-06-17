#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"
ENCODING_DIR="$( cd "${THIS_DIR}/../encodings" && pwd )"

#export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

RAWSOLVE=""
MAXSTEP=""
VARIANT="basic"
POSITIONAL=()

usage(){
    echo "usage: $0 [-h] [-d] [-m <n> ] [-v <variant>]  <instance>"
    echo "       -h            help"
    echo "       -d            enable domain heuristics"
    echo "       -r            raw solve with no post-processing"
    echo "       -g            generate ground text output only"
    echo "       -m <number>   maxstep constant"
    echo "       -v <variant>  different variant"
    exit 1
}

while [[ $# -gt 0 ]]; do
    key=$1

    case $key in
        -h)
            usage
            ;;
        -d)
            OPTIONS="${OPTIONS} --heuristic=Domain"
            shift
            ;;
        -m)
            MAXSTEP="true"
            if [ "$2" != "0" ]; then
                OPTIONS="${OPTIONS} -c maxstep=$2"
            fi
            shift ; shift
            ;;
        -v)
            VARIANT="$2"
            shift ; shift
            ;;
        -g)
            RAWSOLVE="true"
            OPTIONS="${OPTIONS} --text"
            shift
            ;;
        -r)
            RAWSOLVE="true"
            OPTIONS="${OPTIONS} --stats"
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional arguments

if [ "$1" == "" ]; then
    usage
fi

if [ "$MAXSTEP" == "" ]; then
    OPTIONS="${OPTIONS} -c maxstep=30"
fi

BASE="walk"
ASP="${ENCODING_DIR}/${BASE}_${VARIANT}.lp"

CLINGODLFACTS="${THIS_DIR}/clingo-dl-facts.sh"
CLINGOFACTS="${THIS_DIR}/clingo-facts.sh"
CLINGODL="clingo-dl"

>&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
>&2 echo ""

#Just run the solver
if [ "${RAWSOLVE}" != "" ]; then
    ${CLINGODL} ${OPTIONS} ${ASP} $@
    exit 1
fi

# To pretty print the output
#${CLINGODLFACTS} ${OPTIONS} ${ASP}  $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_debug.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} ${OPTIONS} ${ASP}  $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" -

#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS}  "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/solution_checker.lp -

${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${TESTS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${TESTS_DIR}/user_output.lp ${TESTS_DIR}/solution_checker.lp -



