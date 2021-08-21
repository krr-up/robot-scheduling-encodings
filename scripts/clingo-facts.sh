#!/usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLINGO=clingo

#${CLINGO} $@ --verbose=0 --quiet=1,2,2 --out-atomf="%s."
#${CLINGO_DL} $@ --verbose=0 --quiet=1,2,2 --out-atomf="%s." | sed '$d' | sed 's/\. /\.\n'/g

# FACT_OUTPUT=--out-atomf="%s."
FACT_OUTPUT="--out-atomf="%s.""

${CLINGO} $@ --verbose=0 --quiet=1,2,2 ${FACT_OUTPUT} | sed '$s/^UNSATISFIABLE/% Unsatisfiable problem\n\n#false.\n/' | sed 's/^SATISFIABLE//' | sed 's/^OPTIMUM FOUND//' | sed 's/\. /\.\n'/g


