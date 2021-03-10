% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import sys
import networkx as nx
from clorm import func, simple_predicate, alias, notin_, in_, ph1_
from clorm.clingo import Control
from common_data_model import Task, Assignment, TaskSequence
from path_dl_encoding_data_model import Move, Visit, Arrive, Exit, DlArrive, DlExit

Ass=Assignment
TSeq=TaskSequence
Arr=DlArrive
Exit=DlExit

# -------------------------------------------------------------------------------
# Input that is passed straight out: depends/3, assignment/2, task/2,
# task_sequence/2.
# -------------------------------------------------------------------------------



# -------------------------------------------------------------------------------
# Add a list of visits as attributes to task graph nodes
# -------------------------------------------------------------------------------

def add_visits(G,fb):
    qVisits = fb.query(Visit,Arr,Exit)\
                .join(Visit.tid == Arr.a.tid, Visit.tid == Exit.e.tid,
                      Visit.vertex == Arr.a.vertex,
                      Visit.vertex == Exit.e.vertex)\
                .order_by(Visit.tid, Arr.t)\
                .group_by()\
                .select(Visit.vertex,Arr.t,Exit.t)
    for t, vis in qVisits.all():
        G.add_node(t,visits=list(vis))

# -------------------------------------------------------------------------------
# Add everything else from into the task graph
# -------------------------------------------------------------------------------
def add_others(G,fb):
    qTSeq = fb.query(TSeq).select(TSeq.first,TSeq.second)
    qTask = fb.query(Task,Ass)\
              .join(Task.tid == Ass.tid)\
              .select(lambda t,a: (t.tid, {"robot" : a.rid, "vertex" : t.vertex}))
    G.add_nodes_from(qTask.all())
    G.add_edges_from(qTSeq.all())

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
        tasks = list(nx.topological_sort(sg))
        numtasks=len(tasks)
        at=-1
        for tc, tid in enumerate(tasks):
            visits = sg.nodes[tid]["visits"]
            numvisits=len(visits)
#            print("Task {}\n".format(tid))
            for vc,(v,a,e) in enumerate(visits):
#                print("visit {} {} :({},{},{}).".format(rid,tid,v,a,e))
                if vc > 0 or tc == 0: at = a
                if vc == numvisits - 1:
                    actions.append("action({},{},{},{}).".format(tid,v,a,e))
                if tc < numtasks - 1 and vc == numvisits -1: continue
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
    unifier=[ Task, Ass, TSeq, Move, Visit, Arr, Exit ]
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
