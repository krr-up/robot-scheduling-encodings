% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import sys
import networkx as nx
from clorm import func, simple_predicate, alias, notin_, in_, ph1_
from clorm.clingo import Control
from common_data_model import Task, Assignment, TaskSequence
from walk_dl_encoding_data_model import Walk, Proj, Arrive, Exit, DlArrive, DlExit

Ass=Assignment
TSeq=TaskSequence
Arr=DlArrive
Exit=DlExit

# -------------------------------------------------------------------------------
# Input that is passed straight out: depends/3, assignment/2, task/2,
# task_sequence/2.
# -------------------------------------------------------------------------------


# -------------------------------------------------------------------------------
# Print walk by robot
# -------------------------------------------------------------------------------

def print_walk(fb):
    qWalks = fb.query(Walk,Arr,Exit)\
               .join(Walk.rid == Arr.a.rid, Walk.rid == Exit.e.rid,
                     Walk.step == Arr.a.step,Walk.step == Exit.e.step)\
               .order_by(Walk.rid,Walk.step).group_by()\
               .select(Walk.rid,Walk.step,Walk.vertex,Arr.t,Exit.t)

    for r, walk in qWalks.all():
#        print("Robot: {}".format(r))
        for w in walk:
            print("walk({},{},{},{},{}).".format(*w))


# -------------------------------------------------------------------------------
# Print the robot actions
# -------------------------------------------------------------------------------

def print_action(fb):
    qActions = fb.query(Proj,Ass,Walk,Arr,Exit)\
                 .join(Proj.tid == Ass.tid, Ass.rid == Walk.rid,
                       Walk.rid == Arr.a.rid, Walk.rid == Exit.e.rid,
                       Proj.step == Walk.step,
                       Walk.step == Arr.a.step, Walk.step == Exit.e.step)\
                 .select(Proj.tid,Walk.vertex,Arr.t,Exit.t)

    for a in qActions.all():
        print("action({},{},{},{}).".format(*a))

# -------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------

def main(ctrl_):
    unifier=[ Task, Ass, TSeq, Walk, Proj, Arr, Exit ]
    ctrl=Control(control_=ctrl_,unifier=unifier)

#    ctrl.configuration.solve.quiet = 2
    opt_mode = str(ctrl.configuration.solve.opt_mode)

    ctrl.ground([("base",[])])

    fb=None
    with ctrl.solve(yield_=True) as sh:
        for model in sh:
            fb = model.facts(shown=True)
            if opt_mode == "optN" and model.optimality_proven:
                print_output(fb)

    if fb is None:
        raise SystemError("Unsatisfiable")
    if opt_mode != "optN":
        print_walk(fb)
        print_action(fb)

    sys.stderr.flush()
    sys.stdout.flush()

#end.
