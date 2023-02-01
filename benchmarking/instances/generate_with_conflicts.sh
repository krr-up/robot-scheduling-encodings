#!/usr/bin/env bash

# -------------------------------------------------------------------------------------------------
# A script to add the map conflict data
# -------------------------------------------------------------------------------------------------

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"
MC_DIR="2m_width"
IN_DIR="dorabot"
OUT_DIR="dorabot_with_conflicts_2m"

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
    for i in $MC_DIR/$prefix*; do
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
    echo "$dir/$filename"
}

run(){
    local infile="$1"
    local dir="$( dirname $infile )"
    local filename="$( basename $infile )"
    local prefix=$(dorabot_prefix $filename)
    local mapfile=$(dorabot_mapfile $prefix)
    local outfile="$(output_file $infile)"

    echo ""
    echo "DIR: ${dir}"
    echo "FILENAME: ${filename}"
    echo "PREFIX: ${prefix}"
    echo "MAPFILE: ${mapfile}"
    echo "OUTFILE: ${outfile}"

    mkdir -p "${OUT_DIR}"
    echo "From '${infile}' and '$mapfile' creating '$outfile'"
#    return
    cat $infile $mapfile > $outfile
}


for i in $IN_DIR/*.lp; do
    [ -f "$i" ] || break

    run $i
done
