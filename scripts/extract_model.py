#!/usr/bin/env python

# ------------------------------------------------------------------------------
# Takes the standard output from clingo (or as generated by the runsolver) where
# the answer sets are in lines starting with "Answer:" and turn the model into a
# set of ASP facts.
# ------------------------------------------------------------------------------
import os
import math
import sys
import re
import codecs
import argparse
import time
import shlex
import subprocess
from datetime import timedelta

argparser = argparse.ArgumentParser()
argparser.add_argument("rawfile", type=str, help="Clingo generated raw file or - for stdin")
argparser.add_argument("--id", type=int, help="Id of answer to output")
argparser.add_argument("--rawonerror", action='store_true',
                       help="Print the raw output to stderr on error (eg. UNSAT)")
argparser.add_argument("--count", action='store_true',
                       help='Progressively print a model count to stderr')
argparser.add_argument("--fregex", type=str, action='append',
                       help="Progressively print to stderr any facts satisfying the regex")
argparser.add_argument("--exec", type=str,
                       help="Preprocess the text of each model piped into this command")

#from numpy import array, asarray, inf, zeros, minimum, diagonal, newaxis


#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
g_exec=[]
g_starttime=None
g_fregex=[]
g_count=False
g_rawonerror=False
g_lines = []
#-------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
def extract_models(file):
    global g_starttime, g_fregex, g_count, g_rawonerror, g_lines
    answer_re = re.compile(r"^Answer:\s+(?P<val>[0-9]+).*$")

    answers = []
    while True:
        line = file.readline()
        if not line: break
        if g_rawonerror: g_lines.append(line)
        m = answer_re.match(line)
        if not m: continue
        line = file.readline()
        if g_rawonerror: g_lines.append(line)
        answers.append(line)
        if g_fregex or g_count:
            sys.stderr.write("------------------------------------------\n")
            elapsed=time.time()-g_starttime
            sys.stderr.write("Elapsed time: {} ({:.2f}s)\n".format(
                timedelta(seconds=elapsed),elapsed))
        if g_count: sys.stderr.write("Model count: {}\n".format(len(answers)))
        if g_fregex: regex_facts(line)
        if g_fregex or g_count:
            sys.stderr.write("------------------------------------------\n")
    return answers

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

def to_asp(model):
    tmp = model.strip() + "."
    return tmp.replace(") ",").\n")

def factify(asp_facts):
    return asp_facts.splitlines()

def exec(asp_facts):
    if not g_exec: return asp_facts
#    sys.stderr.write("EXECUTING: {}\n".format(g_exec))
    proc = subprocess.Popen(g_exec,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            universal_newlines=True,bufsize=0)
    proc.stdin.write(asp_facts)
    stdout,stderr = proc.communicate()
    if proc.returncode != 0:
        sys.stderr.write("Error running command: {}\n\n".format(g_exec))
        sys.stderr.write(stderr)
        sys.stderr.write("\n")
        sys.exit(1)

    return stdout

# ------------------------------------------------------------------------------
# find facts that match the regex
# ------------------------------------------------------------------------------
def regex_facts(model):
    global g_fregex
    asp_facts = to_asp(model)
    if g_exec: asp_facts = exec(asp_facts)
    for f in factify(asp_facts):
        for regex in g_fregex:
            m = regex.match(f)
            if m:
                sys.stderr.write("{}\n".format(f))
                break
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
SCRIPT_DIR=os.path.dirname(os.path.abspath(__file__))

def main():
    global g_starttime, g_fregex, g_count, g_rawonerror, g_lines, g_exec
    g_starttime = time.time()
    args = argparser.parse_args()

    if args.rawonerror: g_rawonerror = True
    if args.count: g_count = True
    if args.fregex:
        for rstr in args.fregex: g_fregex.append(re.compile(rstr))
    if args.id is None: answer_id=-1
    else: answer_id=args.id
    if args.exec:
        g_exec = shlex.split(args.exec)
    answers=None
    if args.rawfile == "-":
        answers = extract_models(sys.stdin)
    else:
        with open(args.rawfile, errors='ignore', encoding='utf-8') as file:
            answers = extract_models(file)

    try:
        answer = answers[answer_id]
    except IndexError:
        print("\nerror: index {} is not valid for a list of {} elements\n".format(
            answer_id,len(answers)),file=sys.stderr)
        if g_rawonerror:
            for l in g_lines: sys.stderr.write(l)
        else:
            argparser.print_help(sys.stderr)
        return
    asp_facts = to_asp(answer)
    if g_exec: asp_facts = exec(asp_facts)
    for f in factify(asp_facts): print(f)

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    main()
    sys.stderr.flush()
    sys.stdout.flush()
