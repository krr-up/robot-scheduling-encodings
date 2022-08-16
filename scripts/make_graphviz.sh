#!/usr/bin/env bash

# -------------------------------------------------------------------------------------------------
# A script to generate a graphviz diagram from the instance. We consider two types of instances -
# the dorabot instances where we have to look for the node/3 facts in the separate maps
# directory. Here we work out the appropriate map from the file name. The other is philipp's maps
# where the node information is encoded in the node term itself.
# -------------------------------------------------------------------------------------------------

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
MKGV_DIR="${THIS_DIR}/make_graphviz"

TMP_DIR="out"
TMP_FILE="${TMP_DIR}/tmp.default.lp"
CG_FILE="${TMP_DIR}/default.pdf"
OUT_DIR=""

dorabot_prefix(){
    local map=$(echo $1 | sed -n 's/^\(map[0-9]\).*$/\1/p')
    echo "$map"
    return
}

dorabot_mapfile(){
    local prefix=$1

    if [ "$prefix" == "" ] ; then
        echo ""
        return
    fi
    for i in $MKGV_DIR/$prefix*; do
        [ -f "$i" ] || break
        echo "$i"
        return
    done
    echo ""
    return
}

output_file(){
    local dir="$( dirname $1 )"
    local filename="$( basename $1 )"

    if [ "$OUT_DIR" != "" ]; then
        dir="$OUT_DIR"
    fi
    mkdir -p "$dir"
    echo "$dir/$filename.pdf"
}

run(){
    local infile="$1"
    local dir="$( dirname $infile )"
    local filename="$( basename $infile )"
    local prefix=$(dorabot_prefix $filename)
    local mapfile=$(dorabot_mapfile $prefix)
    local outfile="$(output_file $infile)"

    echo "DIR: ${dir}"
    echo "FILENAME: ${filename}"
    echo "PREFIX: ${prefix}"
    echo "MAPFILE: ${mapfile}"
    echo "OUTFILE: ${outfile}"

    mkdir -p "${TMP_DIR}"
    clingo -V0 --quiet=2,2,2 ${MKGV_DIR}/map_to_graphviz.lp $infile $mapfile | sed -e 's/^SATISFIABLE//g' > $TMP_FILE
    clingraph --out=render --engine=neato $TMP_FILE
    echo "Renaming ${CG_FILE} to $outfile"
    mv "${CG_FILE}"  "$outfile"
}

usage(){
    local exe=$(basename $1)
    echo "usage: $exe [-o <output-dir>] <instance>"
    exit 1
}

exe="$0"

while [[ $# -gt 0 ]]; do
    key=$1
    case $key in
        -h)
            usage $exe
            ;;
        -o)
            OUT_DIR="$2"
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
    usage $exe
fi

run $@
