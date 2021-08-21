#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
TESTS_DIR="$( cd "${THIS_DIR}/../tests" && pwd )"
ENCODING_DIR="$( cd "${THIS_DIR}/../encodings" && pwd )"

usage(){
    echo "usage: $0 [-idx ] [-h] [-o ] <instance>"
    echo "       -h            help"
    echo "       -idx <id>      idx"
    echo "       -o <output>   output options: tasks|rtasks|stats|model [stats]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    key=$1

    case $key in
        -h)
            usage
            ;;
        -o)
            OUTPUT="$2"
            shift ; shift
            ;;
        -idx)
            IDX="$2"
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

CLINGOFACTS="${THIS_DIR}/../scripts/clingo-facts.sh"
CLINGO="clingo"
ASPSTATS="${TESTS_DIR}/soln_to_stats.lp"

getmodelallstats(){
    output=$(${THIS_DIR}/extract_model.py --id ${IDX} --rawonerror --count --fregex makespan --fregex replacement - --exec "${CLINGOFACTS} ${ASPSTATS} -")
    echo "$output"
}

# If no output option specified then default to "raw"
if [ "${OUTPUT}" == "" ]; then
    OUTPUT="stats"
fi
if [ "${IDX}" == "" ]; then
    IDX=-1
fi


# Solve and output correctly
if [ "${OUTPUT}" == "tasks" ]; then
    cat $@ | getmodelallstats | ${CLINGO} ${TESTS_DIR}/tasks_to_output.lp -
elif [ "${OUTPUT}" == "rtasks" ]; then
    cat $@ | getmodelallstats | ${CLINGO} -c robots="true" ${TESTS_DIR}/tasks_to_output.lp -
elif [ "${OUTPUT}" == "stats" ]; then
    cat $@ | getmodelallstats > /dev/null
elif [ "${OUTPUT}" == "model" ]; then
    cat $@ | getmodelallstats
else
    echo "Unrecognised output option $OUTPUT"
    usage
fi
