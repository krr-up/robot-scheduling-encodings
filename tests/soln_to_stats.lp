% ----------------------------------------------------------------------------
% Take a path or walk encoding solution and output some important statistics
% about the solution.
%
% Output facts (besides the input facts):
% - replacement(T,T',Value)
% - replacement_geomean(Value)
% - makespan(Value)
%
% ----------------------------------------------------------------------------

#defined proj/2.

#script(python)
import sys
import statistics
import networkx as nx
import matplotlib.pyplot as plt
from clorm import func, simple_predicate, alias, notin_, in_, ph1_, ph2_, notin_, in_, path
from clorm import Predicate, ConstantField, StringField, IntegerField, RawField
from clorm.clingo import Control

class Replacement(Predicate):
    tid1=RawField
    tid2=RawField
    time=IntegerField

Repl=Replacement


# -------------------------------------------------------------------------------
#
# -------------------------------------------------------------------------------

def stats(fb):
    qRepl = fb.query(Repl).select(lambda r : float(r.time))
    tmp = list(qRepl.all())
    if not tmp:
       sys.stderr.write("Warning: no replacement time data\n")
       return

    count = len(tmp)
    minimum = min(tmp)
    maximum = max(tmp)
    mean = statistics.mean(tmp)
    median = statistics.median(tmp)
    geo_mean = statistics.geometric_mean(tmp)

    sys.stdout.write("replacement_count({}).\n".format(count))
    sys.stdout.write("replacement_min(\"{:.2f}\").\n".format(minimum))
    sys.stdout.write("replacement_max(\"{:.2f}\").\n".format(maximum))
    sys.stdout.write("replacement_mean(\"{:.2f}\").\n".format(mean))
    sys.stdout.write("replacement_median(\"{:.2f}\").\n".format(median))
    sys.stdout.write("replacement_geomean(\"{:.2f}\").\n".format(geo_mean))

# -------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------

def main(ctrl_):
    global g_robots
    unifier=[Repl]
    ctrl=Control(control_=ctrl_,unifier=unifier)

#    robots = ctrl.get_const("robots")
#    if robots is not None:
#         g_robots=str(robots)

    ctrl.configuration.solve.quiet = 2
    opt_mode = str(ctrl.configuration.solve.opt_mode)

    ctrl.ground([("base",[])])

    fb=None
    with ctrl.solve(yield_=True) as sh:
        for model in sh:
            fb = model.facts(atoms=True)
            if opt_mode == "optN" and model.optimality_proven:
                stats(fb)

    if fb is None:
        raise SystemError("Unsatisfiable")
    if opt_mode != "optN":
        stats(fb)

    sys.stderr.flush()
    sys.stdout.flush()

#end.

% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------

% Replacement time for a path encoding solution
replacement(T,T',Time'-Time) :- task(T,V),task(T',V'),depends(wait,T,T'),
                                dl(arrive(T,V),Time), dl(arrive(T',V'),Time').


% Replacement time for a walk encoding solution
replacement(T,T',Time'-Time) :- task(T,V),task(T',V'),depends(wait,T,T'),
                                assignment(R,T), assignment(R',T'),
                                proj(T,S), proj(T',S'),
                                dl(arrive(R,S),Time), dl(arrive(R',S'),Time').

% The makespan
makespan(Time)               :- dl(bound,Time).


% The number of distinct time points will be an upper bound on the number of
% steps; that is the maxsteps will be some number less than this.
timepoints(S)                :- S = #count{ Time : dl(_,Time) }.

% ---------------------------------------------------------------------------------

% ---------------------------------------------------------------------------------

%#show.


