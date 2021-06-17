% ----------------------------------------------------------------------------
% Format a (partial) solution to the path encoding and enforce dl
% constraints. Can handle both the fast and full encodings.
%
% Input/Output facts:
% - dl_eq(Variable,Value)
%
% - define a constant output=[noexit|all]
% ----------------------------------------------------------------------------

#defined task_sequence/2.

#script(python)
import sys
from clorm import ConstantField, IntegerField, Predicate, simple_predicate, combine_fields, desc
from clorm.clingo import Control

Exit=simple_predicate("exit",2)
Arrive=simple_predicate("arrive",2)

class Dl(Predicate):
    var=combine_fields([ConstantField,Arrive.Field,Exit.Field])
    value=IntegerField

def main(ctrl_):

    unifier=[Dl]
    ctrl=Control(control_=ctrl_,unifier=unifier)
    ctrl.ground([("base",[])])
    output = ctrl.get_const("output")
    if not output: output="all"
    else: output = output=str(output)

    fb=None
    with ctrl.solve(yield_=True) as sh:
        for model in sh:
            fb = model.facts(atoms=True)

    if fb is None:
        raise SystemError("Unsatisfiable")

    for f in fb.query(Dl).order_by(Dl[1]).all():
        if output == "noexit" and type(f[0]) == Exit: continue
        lestr = "&diff{{ {} - 0 }} <= {}. ".format(f[0],f[1])
        gestr = "&diff{{ 0 - {} }} <= -{}. ".format(f[0],f[1])
        print("{}{}".format(lestr,gestr))

    print()
    sys.stdout.flush()
    sys.stderr.flush()

#end.

#show.
#show move/3.
#show assignment/2.
#show task_sequence/2.

%#show walk/3.
%#show assignment/2.
%#show proj/2.
%#show dl_eq/2.


