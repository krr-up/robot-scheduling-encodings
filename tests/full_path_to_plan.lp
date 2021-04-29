% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import sys
import networkx as nx
from clorm import func, simple_predicate, alias, notin_, in_, ph1_, ph2_
from clorm.clingo import Control
from common_data_model import Task, Assignment, TaskSequence
from full_path_data_model import Move, Path, Visit, Arrive, Exit,\
    DlArrive, DlExit

Ass=Assignment
TSeq=TaskSequence
Arr=DlArrive
Exit=DlExit

# -------------------------------------------------------------------------------
# Input that is passed straight out: depends/3, assignment/2, task/2,
# task_sequence/2.
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
# Add a list of visits as attributes to path graph nodes
# -------------------------------------------------------------------------------

def add_visits(G,fb):
    qArrivals = fb.query(Visit,Arr)\
                  .join(Visit.pid == Arr.a.pid, Visit.vertex == Arr.a.vertex)\
                  .order_by(Visit.pid, Arr.t)\
                  .group_by()\
                  .select(Visit.vertex,Arr.t)

    qExits = fb.query(Visit,Exit)\
                .join(Visit.pid == Exit.e.pid, Visit.vertex == Exit.e.vertex)\
                .where(Visit.pid == ph1_, Visit.vertex == ph2_)\
                .select(Exit.t)

    for p, vis in qArrivals.all():
        nlist = []
        for v,a in vis:
            tmp = list(qExits.bind(p,v).all())
            if tmp: nlist.append((v,a,tmp[0]))
            else: nlist.append((v,a,-1))

        G.add_node(p,visits=nlist)

# -------------------------------------------------------------------------------
# Add everything else from into the task graph
# -------------------------------------------------------------------------------
def add_others(G,fb):
    qTask = fb.query(Task,Ass)\
              .join(Task.tid == Ass.tid)\
              .select(lambda t,a: (t.tid, {"robot" : a.rid, "vertex" : t.vertex}))
    G.add_nodes_from(qTask.all())

    qTSeq = fb.query(TSeq).select(TSeq.first,TSeq.second)
    G.add_edges_from(qTSeq.all())

    qHomePath = fb.query(Path)\
        .where(notin_(Path.pid, fb.query(Task).select(Task.tid)))\
        .select(lambda p: (p.pid, {"robot" : p.pid, "vertex" : p.vertex}))
    G.add_nodes_from(qHomePath.all())

    qLastTask = fb.query(TSeq,Ass)\
                  .join(TSeq.second == Ass.tid)\
                  .where(notin_(TSeq.second, fb.query(TSeq).select(TSeq.first)))\
                  .select(Ass.tid, Ass.rid)
    G.add_edges_from(qLastTask.all())


# -------------------------------------------------------------------------------
#
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
# Turn the task graph into walk by robot - Need to turn the visits into a walk
# -------------------------------------------------------------------------------

def print_walks_and_actions(fb):
    G = nx.DiGraph()
    add_visits(G,fb)
    add_others(G,fb)

    # Get the weakly connected components - each subgraph will be the tasks for
    # a single robot
    actions =[]
    for c in nx.weakly_connected_components(G):
        sg = G.subgraph(c)
        t,a=next(iter(sg.nodes.data()))
        rid = a["robot"]
#        print("\nRobot {}".format(rid))
        step=0
        paths = list(nx.topological_sort(sg))
        numpaths=len(paths)
        at=-1
        for pcount, pid in enumerate(paths):
            visits = sg.nodes[pid]["visits"]
            numvisits=len(visits)
#            print("Path {}\n".format(pid))
            for vc,(v,a,e) in enumerate(visits):
#                print("visit {} {} :({},{},{}).".format(rid,pid,v,a,e))
                if vc > 0 or pcount == 0: at = a
                if vc == numvisits - 1 and pcount < numpaths -1:
                    actions.append("action({},{},{},{}).".format(pid,v,a,e))
                if pcount < numpaths - 1 and vc == numvisits -1: continue
                print("walk({},{},{},{},{}).".format(rid,step,v,at,e))
                step += 1
                at=a

    # Print the actions
    print()
    for a in actions: print(a)



# -------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------

def main(ctrl_):
    unifier=[ Task, Path, Ass, TSeq, Move, Visit, Arr, Exit ]
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
        print_walks_and_actions(fb)

    sys.stderr.flush()
    sys.stdout.flush()

#end.
