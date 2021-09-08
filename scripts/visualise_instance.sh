#!/usr/bin/env bash

SCRIPT="$( readlink -f ${BASH_SOURCE[0]} )"
THIS_DIR="$( cd "$( dirname ${SCRIPT} )" && pwd )"

usage(){
    echo "usage: $0 <instance>"
    exit 1
}

python ${THIS_DIR}/../visualizer/visualizer.py -f $1

