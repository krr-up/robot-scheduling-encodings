% ----------------------------------------------------------------------------
% Takes a walk (produced by the walk encoding) and outputs in a nice way.
% ----------------------------------------------------------------------------

#script(python)
import sys
import networkx as nx
from clorm import func, simple_predicate, alias, notin_, in_, ph1_, refine_field
from clorm import Predicate, IntegerField, RawField, ConstantField
from clorm.clingo import Control


class Walk(Predicate):
    rid=RawField
    step=IntegerField
    vertex=RawField
    atime=IntegerField
    etime=IntegerField

class Action(Predicate):
    tid=RawField
    vertex=RawField
    stime=IntegerField
    etime=IntegerField

class Assn(Predicate):
    rid=RawField
    tid=RawField
    class Meta: name="assignment"

class Conflict(Predicate):
    ctype=ConstantField
    walk1=Walk.Field
    walk2=Walk.Field
    class Meta: name="walkconflict"

class Err(Predicate):
    errterm=RawField

class NoErrors(Predicate):
    pass
    class Meta: name="noerrors"

class Dl(Predicate):
    bound=refine_field("BoundField",ConstantField,["bound"])
    time=IntegerField

class WalkLength(Predicate):
    rid=RawField
    steps=IntegerField
    class Meta: name="walk_length"

# -------------------------------------------------------------------------------
# Global variables
# -------------------------------------------------------------------------------
g_econf = {}
g_vconf = {}

# -------------------------------------------------------------------------------
# Loadup any conflicting walks
# -------------------------------------------------------------------------------

def load_conflicts(fb):
    global g_econf, g_vconf
    def addconf(cdict,walk1,walk2):
        if walk1 not in cdict: cdict[walk1] = set()
        if walk2 not in cdict: cdict[walk2] = set()
        cdict[walk1].add(walk2)
        cdict[walk2].add(walk1)

    qConflicts = fb.query(Conflict)
    for conflict in qConflicts.all():
        if conflict.ctype == "edge":
            addconf(g_econf,conflict.walk1,conflict.walk2)
        else:
            addconf(g_vconf,conflict.walk1,conflict.walk2)

#    if g_econf or g_vconf: print("-------------")
#    if g_econf: print("EDGE CONFLICTS: {}".format(g_econf))
#    if g_vconf: print("VERTEX CONFLICTS: {}".format(g_vconf))
#    if g_econf or g_vconf: print("-------------\n")


# -------------------------------------------------------------------------------
#
# -------------------------------------------------------------------------------

def conflict_report(walk):
    vconf = g_vconf.get(walk,None)
    econf = g_econf.get(walk,None)

    if not vconf and not econf: return ""
    vstr = "vertex: {}".format(list(vconf)) if vconf else ""
    estr = "edge: {}".format(list(econf)) if econf else ""

    if vconf and not econf: return "[{}]".format(vstr)
    if econf and not vconf: return "[{}]".format(estr)
    return "[{}, {}]".format(vstr,estr)

# -------------------------------------------------------------------------------
#
# -------------------------------------------------------------------------------
def match_action(action,walk):
    if not action: return False
    if action.stime > walk.etime: return False
    if (walk.atime <= action.stime) and (walk.etime >= action.etime) and \
       (Action.vertex == walk.vertex): return True

    msg=("Mismatch: {} and {}".format(action,walk))
    raise RuntimeError(msg)


# -------------------------------------------------------------------------------
# Print walk by robot
# -------------------------------------------------------------------------------

def print_walk(fb):
    qActions = fb.query(Action,Assn)\
                 .join(Action.tid == Assn.tid)\
                 .where(Assn.rid == ph1_)\
                 .order_by(Action.stime)\
                 .select(Action)
    qWalks = fb.query(Walk).group_by(Walk.rid).order_by(Walk.step)\
               .select(Walk)

    for r,walks in qWalks.all():
        actions=qActions.bind(r).all()
        action=next(actions,None)
        print("Robot: {}".format(r))
        for walk in walks:
            tmp1 = "\t({},{},{},{})".format(walk.step,walk.vertex,walk.atime,walk.etime)
            tmp2 = conflict_report(walk)
            if tmp2: tmp1 = "{} {}".format(tmp1,tmp2)
            if action:
                alist = []
                while match_action(action,walk):
                    alist.append(str(action.tid))
                    action=next(actions,None)
                if alist:
                    print("{} => task action: {}".format(tmp1,", ".join(alist)))
                else:
                    print("{}".format(tmp1))
            else:
                print("{}".format(tmp1))


# -------------------------------------------------------------------------------
# Solution checker output
# -------------------------------------------------------------------------------
def print_checker(fb):
    print("")
    WL=WalkLength
    qWL=fb.query(WL).order_by(WL.rid).select(WL.rid,WL.steps)
    for r,s in qWL.all(): print("Robot {} steps = {}".format(r,s))

    qDlb=fb.query(Dl).select(Dl.time)
    for t in qDlb.all():
        print("Makespan: {}".format(t))

    for err in fb.query(Err).select(Err.errterm).all():
        print("Error in: {}".format(errterm))
    if NoErrors() in fb:
        print("The plan is free from errors")
# -------------------------------------------------------------------------------
# Print output
# -------------------------------------------------------------------------------
def print_output(fb):
    load_conflicts(fb)
    print_walk(fb)
    print_checker(fb)

# -------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------

def main(ctrl_):
    unifier=[ Walk, Action, Assn, Conflict, Err, NoErrors, Dl, WalkLength]
    ctrl=Control(control_=ctrl_,unifier=unifier)

#    ctrl.configuration.solve.quiet = 2
    opt_mode = str(ctrl.configuration.solve.opt_mode)

    ctrl.ground([("base",[])])

    fb=None
    with ctrl.solve(yield_=True) as sh:
        for model in sh:
            fb = model.facts(atoms=True)
            if opt_mode == "optN" and model.optimality_proven:
                print_output(fb)

    if fb is None:
        raise SystemError("Unsatisfiable")
    if opt_mode != "optN":
        print_output(fb)

    sys.stderr.flush()
    sys.stdout.flush()

#end.

walkconflict(vertex,walk(R,S,V,A,Ex), walk(R',S',V',A',Ex')) :-
                                walk(R,S,V,A,Ex), walk(R',S',V',A',Ex'),
                                R != R', Ex >= 0, Ex' >= 0,
                                conflict(v,V,V'), A <= A', Ex >= Ex'.

walkconflict(edge,walk(R,S,V1,A1,Ex1), walk(R',S',V1',A1',Ex1')) :-
                                 walk(R,S,V1,A1,Ex1), walk(R,S+1,V2,A2,Ex2),
                                 walk(R',S',V1',A1',Ex1'), walk(R',S'+1,V2',A2',Ex2'),
                                 E=(V1,V2), E'=(V1',V2'),R != R',
                                 conflict(e,E,E'), Ex1 <= Ex1', A2 >= A2'.

#show.
%#show walkconflict/3.
%#show before/3.
%#show dl/2.

%#show on_minpath/3.
%#show path_min_dist/2.
%#show shortest_path/4.
