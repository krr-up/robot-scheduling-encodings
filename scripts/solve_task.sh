#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"
ENCODING_DIR="$( cd "${THIS_DIR}/../encodings" && pwd )"

VARIANT="pre"
POSITIONAL=()
OPTIONS=""

flags(){
    local line=$(head -n 1 $1)
    local flags=$(echo $line | sed -n "s/^%!flags!\s*\(.*\)$/\1/p")
    echo "$flags"
    return 0
}

usage(){
    echo "usage: $0 [-h] [-d] [-v <variant>] <instance>"
    echo "       -h            help"
    echo "       -d            enable domain heuristics"
    echo "       -o <output>     output options: raw|text|tasks|rdisplay|display  [raw]"
    echo "       -v <variant>    different variant [pre]"
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

BASE="task_assn"
ASP="${ENCODING_DIR}/${BASE}_${VARIANT}.lp"

CLINGOFACTS="${THIS_DIR}/../scripts/clingo-facts.sh"
CLINGO="clingo"
GETMODEL="${THIS_DIR}/extract_model.py --id -1 --rawonerror --count --fregex 'dl\(bound' -"

# If no output option specified then default to "raw"
if [ "${OUTPUT}" == "" ]; then
    OUTPUT="raw"
fi

# Solve and output correctly
if [ "${OUTPUT}" == "raw" ]; then
    OPTIONS="${OPTIONS} --stats"
    >&2 echo "Executing: clingo ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGO} ${OPTIONS} ${ASP} $@
elif [ "${OUTPUT}" == "text" ]; then
    OPTIONS="${OPTIONS} --text"
    >&2 echo "Executing: clingo ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGO} ${OPTIONS} ${ASP} $@
elif [ "${OUTPUT}" == "tasks" ]; then
    >&2 echo "Executing: clingo ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGO} ${OPTIONS} ${ASP} $@ | ${GETMODEL}
elif [ "${OUTPUT}" == "display" ]; then
    >&2 echo "Executing: clingo ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGO} ${OPTIONS} ${ASP} $@ | ${GETMODEL} | ${CLINGO} $@ ${TESTS_DIR}/tasks_to_output.lp -
elif [ "${OUTPUT}" == "rdisplay" ]; then
    >&2 echo "Executing: clingo ${OPTIONS} ${ASP} $@ "
    >&2 echo ""
    ${CLINGO} ${OPTIONS} ${ASP} $@ | ${GETMODEL} | ${CLINGO} -c robots="true" $@ ${TESTS_DIR}/tasks_to_output.lp -
else
    echo "Unrecognised output option $OUTPUT"
    usage
fi
