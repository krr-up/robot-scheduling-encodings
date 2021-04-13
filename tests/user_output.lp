% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import sys
import networkx as nx
from clorm import func, simple_predicate, alias, notin_, in_, ph1_
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
    qWalks = fb.query(Walk).order_by(Walk.rid,Walk.step).group_by()\
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
# Print output
# -------------------------------------------------------------------------------
def print_output(fb):
    load_conflicts(fb)
    print_walk(fb)

# -------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------

def main(ctrl_):
    unifier=[ Walk, Action, Assn, Conflict ]
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
#show before/3.
#show dl/2.