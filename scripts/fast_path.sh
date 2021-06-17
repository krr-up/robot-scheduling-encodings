#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"
ENCODING_DIR="$( cd "${THIS_DIR}/../encodings" && pwd )"

#export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

VARIANT="basic"
POSITIONAL=()
OPTIONS=""

usage(){
    echo "usage: $0 [-h] [-d] [-v <variant>] <instance>"
    echo "       -h              help"
    echo "       -d              enable domain heuristics"
    echo "       -o <output>     output options: raw|text|paths|fpaths|walk|fwalk  [raw]"
    echo "       -v <variant>    different variant"
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
        -o)
            OUTPUT="$2"
            shift ; shift
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
ASP="${ENCODING_DIR}/${BASE}_${VARIANT}.lp"

CLINGODLFACTS="${THIS_DIR}/clingo-dl-facts.sh"
CLINGOFACTS="${THIS_DIR}/clingo-facts.sh"
CLINGODL="clingo-dl"

# If no output option specified then default to "raw"
if [ "${OUTPUT}" == "" ]; then
    OUTPUT="raw"
fi

# Solve and output correctly
if [ "${OUTPUT}" == "raw" ]; then
    OPTIONS="${OPTIONS} --stats"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@
elif [ "${OUTPUT}" == "text" ]; then
    OPTIONS="${OPTIONS} --text"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@
elif [ "${OUTPUT}" == "walk" ]; then
    ASP="$ENCODING_DIR/path/show_all.lp ${ASP}"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${TESTS_DIR}/paths_to_walk.lp" -
elif [ "${OUTPUT}" == "fwalk" ]; then
    ASP="$ENCODING_DIR/path/show_all.lp ${ASP}"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${TESTS_DIR}/paths_to_walk.lp" - | ${CLINGOFACTS} "${TESTS_DIR}/walk_to_fwalk.lp" -
elif [ "${OUTPUT}" == "paths" ]; then
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODLFACTS} ${OPTIONS} ${ASP} $@
elif [ "${OUTPUT}" == "fpaths" ]; then
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} ${FPATHS_FILTER} "${TESTS_DIR}/paths_to_fpaths.lp" -
else
    echo "Unrecognised output option $OUTPUT"
    usage
fi


# To pretty print the output
#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_debug.lp" -

# To check the solution - make sure the plan is collision free
#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" -

#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS}  "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/solution_checker.lp -

#${CLINGODLFACTS} ${OPTIONS} ${ASP} $@ | ${CLINGOFACTS} "${THIS_DIR}/${BASE}_to_plan.lp" - | ${CLINGOFACTS} ${THIS_DIR}/user_output.lp ${THIS_DIR}/solution_checker.lp -


