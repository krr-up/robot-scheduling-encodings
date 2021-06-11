% ----------------------------------------------------------------------------
% Format the walk encoding for cleaner output and add extra rules to set the
% maxstep and enforce dl constraints.
%
% Input/Output facts:
% - assignment(Robot,Task)
% - walk(Robot,Step,Vertex)
% - proj(Task,Step)
% - dl_eq(Variable,Value)
%
% ----------------------------------------------------------------------------

#script(python)
import sys
from clorm import simple_predicate, desc
from clorm.clingo import Control

Assignment = simple_predicate("assignment",2)
Walk = simple_predicate("walk",3)
Proj = simple_predicate("proj",2)
DlEq = simple_predicate("dl_eq",2)
def main(ctrl_):

    unifier=[Assignment,Walk,Proj,DlEq]
    ctrl=Control(control_=ctrl_,unifier=unifier)
    ctrl.ground([("base",[])])

    fb=None
    with ctrl.solve(yield_=True) as sh:
        for model in sh:
            fb = model.facts(atoms=True)

    if fb is None:
        raise SystemError("Unsatisfiable")
    maxstep = fb.query(Walk).order_by(desc(Walk[1])).select(Walk[1]).first()
    print("#const maxstep={}.\n".format(maxstep))

    for f in fb.query(Assignment).order_by(Assignment[0]).all(): print("{}.".format(f))
    for f in fb.query(Walk).order_by(Walk[0],Walk[1]).all():  print("{}.".format(f))
    for f in fb.query(Proj).order_by(Proj[1]).all():  print("{}.".format(f))
    print()
    for f in fb.query(DlEq).order_by(DlEq[1]).all():
        lestr = "&diff{{ {} - 0 }} <= {}. ".format(f[0],f[1])
        gestr = "&diff{{ 0 - {} }} <= -{}. ".format(f[0],f[1])
        print("{}{}".format(lestr,gestr))
#        print("{} {} % {}.".format(lestr,gestr,f))

#        swalk = "walk({},{},{}).".format(w[0],w[1],w[2])       #.ljust(25)
#        sarr  = "dl(arrive({},{}),{}).".format(w[0],w[1],w[3]) #.ljust(25)
#        sexit = "dl(exit({},{}),{}).".format(w[0],w[1],w[4])   #.ljust(25)
#        print("{} {} {}\n".format(swalk,sarr,sexit))

    print()
    sys.stdout.flush()

#end.

#show.
%#show walk/3.
%#show assignment/2.
%#show proj/2.
%#show dl_eq/2.


