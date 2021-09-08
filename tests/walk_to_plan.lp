% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import sys
import networkx as nx
from clorm import func, simple_predicate, alias, notin_, in_, ph1_, ph2_
from clorm import Predicate, ConstantField, StringField, IntegerField, RawField
from clorm.clingo import Control

class Task(Predicate):
    tid=RawField
    vertex=RawField

class Assignment(Predicate):
    rid=RawField
    tid=RawField

class TaskSequence(Predicate):
    first=RawField
    second=RawField
    class Meta: name="task_sequence"

class Walk(Predicate):
    rid=RawField
    step=IntegerField
    vertex=RawField

class Proj(Predicate):
    tid=RawField
    step=IntegerField

class Arrive(Predicate):
    rid=RawField
    step=IntegerField

class Exit(Predicate):
    rid=RawField
    step=IntegerField

class DlArrive(Predicate):
    a=Arrive.Field
    t=IntegerField
    class Meta: name = "dl"

class DlExit(Predicate):
    e=Exit.Field
    t=IntegerField
    class Meta: name = "dl"


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

    qExits = fb.query(Walk,Exit)\
                .join(Walk.rid == Exit.e.rid, Walk.step == Exit.e.step)\
                .select(lambda w,e : ((w.rid,w.step), e.t))
    exits = { k : v for k,v in qExits.all() }

    qWS = fb.query(Walk,Arr)\
            .join(Walk.rid == Arr.a.rid, Walk.step == Arr.a.step)\
            .order_by(Walk.rid,Arr.t)\
            .select(lambda w,a : (w.rid,w.step, w.vertex, a.t, exits[(w.rid,w.step)]))

    for ws in qWS.all():
        print("walk({},{},{},{},{}).".format(*ws))


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
