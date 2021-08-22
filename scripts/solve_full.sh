#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"
ENCODING_DIR="$( cd "${THIS_DIR}/../encodings" && pwd )"

#export PYTHONPATH="$THIS_DIR:${PYTHONPATH}"

BASE="full_path"
VARIANT="basic"
POSITIONAL=()
OPTIONS=""
FPATHS_FILTER=""

flags(){
    local line=$(head -n 1 $1)
    local flags=$(echo $line | sed -n "s/^%!flags!\s*\(.*\)$/\1/p")
    echo "$flags"
    return 0
}

list_variants(){
    for v in "${ENCODING_DIR}/${BASE}_"*.lp; do
        v="${v##*/${BASE}_}"
        v="${v%.lp}"
        echo "          ${v} "
    done
}

usage(){
    echo "usage: $0 [-h] [-d] [-v <variant>] <instance>"
    echo "       -h              help"
    echo "       -d              enable domain heuristics"
    echo "       -o <output>     output options: raw|text|meta|paths|fpaths|walk|fwalk  [raw]"
    echo "       -v <variant>    different variant (default: ${VARIANT})"
    echo "       -f              filter out the dl exit facts when outputting formatted paths"
    echo ""
    echo "       Variants:"
    list_variants
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
        -f)
            FPATHS_FILTER="-c output=noexit"
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

ASP="${ENCODING_DIR}/${BASE}_${VARIANT}.lp"

FLAGS=$(flags ${ASP})
if [ "$FLAGS" != "" ]; then
    OPTIONS="${FLAGS} ${OPTIONS}"
fi

CLINGODLFACTS="${THIS_DIR}/clingo-dl-facts.sh"
CLINGOFACTS="${THIS_DIR}/clingo-facts.sh"
CLINGO="clingo"
CLINGODL="clingo-dl"
ASPSTATS="${TESTS_DIR}/soln_to_stats.lp"


getmodelallstats(){
    output=$(${THIS_DIR}/extract_model.py --id -1 --rawonerror --count --fregex makespan --fregex replacement - --exec "${CLINGOFACTS} ${ASPSTATS} -")
    echo "$output"
}

getmodelbasic(){
    output=$(${THIS_DIR}/extract_model.py --id -1 --rawonerror --count --fregex makespan --fregex replacement_ - --exec "${CLINGOFACTS} ${ASPSTATS} -")
    echo "$output"
}

# If no output option specified then default to "raw"
if [ "${OUTPUT}" == "" ]; then
    OUTPUT="raw"
fi

# Solve and output correctly
if [ "${OUTPUT}" == "raw" ]; then
    OPTIONS="${OPTIONS} --stats=2"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@

elif [ "${OUTPUT}" == "text" ]; then
    OPTIONS="${OPTIONS} --text"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@

elif [ "${OUTPUT}" == "stats" ]; then
    ASP="$ENCODING_DIR/path/show_all.lp ${ASP}"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@ | getmodelallstats  > /dev/null

elif [ "${OUTPUT}" == "meta" ]; then
    ASP="$ENCODING_DIR/path/show_all.lp ${ASP}"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@ | getmodelbasic > /dev/null

elif [ "${OUTPUT}" == "walk" ]; then
    ASP="$ENCODING_DIR/path/show_all.lp ${ASP}"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@ | getmodelbasic | ${CLINGOFACTS} "${TESTS_DIR}/paths_to_walk.lp" -

elif [ "${OUTPUT}" == "fwalk" ]; then
    ASP="$ENCODING_DIR/path/show_all.lp ${ASP}"
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@ | getmodelbasic | ${CLINGOFACTS} "${TESTS_DIR}/paths_to_walk.lp" - | ${CLINGOFACTS} "${TESTS_DIR}/walk_to_fwalk.lp" -

elif [ "${OUTPUT}" == "paths" ]; then
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@ | getmodelbasic

elif [ "${OUTPUT}" == "fpaths" ]; then
    >&2 echo "Executing: clingo-dl ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGODL} ${OPTIONS} ${ASP} $@ | getmodelbasic | ${CLINGOFACTS} ${FPATHS_FILTER} "${TESTS_DIR}/paths_to_fpaths.lp" -

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


