#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

RAWSOLVE=""
VARIANT="basic"
POSITIONAL=()
OPTIONS=""

usage(){
    echo "usage: $0 [-h] [-d] [-v <variant>] <instance>"
    echo "       -h            help"
    echo "       -d            enable domain heuristics"
    echo "       -r            raw solve with no post-processing"
    echo "       -g            generate ground text output only"
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

BASE="fast_path"
ASP="${THIS_DIR}/../encodings/${BASE}_${VARIANT}.lp"

CLINGODLFACTS="${THIS_DIR}/../scripts/clingo-dl-facts.sh"
CLINGOFACTS="${THIS_DIR}/../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"

>&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
>&2 echo ""

#Just run the solver
if [ "${RAWSOLVE}" != "" ]; then
    ${CLINGODL} ${OPTIONS} ${ASP} $@
    exit 1
fi

${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/to_walk.lp" -

# To pretty print the output
#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_debug.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" -

#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS}  "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/solution_checker.lp -

#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/user_output.lp ${THIS_DIR}/solution_checker.lp -


