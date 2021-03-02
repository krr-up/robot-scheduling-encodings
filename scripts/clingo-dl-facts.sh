#!/usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#CLINGO_DL=${THIS_DIR}/../python/clingo-dl
CLINGO_DL=clingo-dl

#${CLINGO_DL} $@ --verbose=0 --quiet=1,2,2 --out-atomf="%s."
#${CLINGO_DL} $@ --verbose=0 --quiet=1,2,2 --out-atomf="%s." | sed '$d' | sed 's/\. /\.\n'/g

${CLINGO_DL} $@ --verbose=0 --quiet=1,2,2 --out-atomf="%s." | sed '$s/^UNSATISFIABLE/% Unsatisfiable problem\n\n#false.\n/' | sed '$s/^SATISFIABLE//' | sed '$s/^OPTIMUM FOUND//' | sed 's/\. /\.\n'/g
