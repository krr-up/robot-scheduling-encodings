% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import sys
import itertools
import networkx as nx
from clorm import func, simple_predicate, alias, notin_, in_, ph1_
from clorm.clingo import Control
from common_data_model import Task, Assignment, TaskSequence
from fast_encoding_data_model import Path, Move, Visit, Arrive, DlArrive

Ass=Assignment
TSeq=TaskSequence
Arr=DlArrive

# -------------------------------------------------------------------------------
# Global variables
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
# Print the task sequence by robot
# -------------------------------------------------------------------------------
def print_nx_task_sequence(G,fb):
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

    # Make sure there are no cycles
    if not nx.is_directed_acyclic_graph(G):
        print("NOT A DAG")
        return
    # Get the weakly connected components - each subgraph will be the paths for
    # a single robot
    print("Path sequences:")
    for c in nx.weakly_connected_components(G):
        sg = G.subgraph(c)
        t,a=next(iter(sg.nodes.data()))
        r = a["robot"]
        print("Robot {}:".format(r))
        for t in nx.topological_sort(sg):
            print("\tPath {}".format(t))
            for visit in sg.nodes[t]["visits"]:
                print("\t\t({},{})".format(*visit))
    return G

# -------------------------------------------------------------------------------
# Print moves by robot
# -------------------------------------------------------------------------------

def add_visits(G,fb):
    qVisits = fb.query(Visit,Arr)\
                .join(Visit.pid == Arr.a.pid,
                      Visit.vertex == Arr.a.vertex)\
                .order_by(Visit.pid, Arr.t)\
                .group_by()\
                .select(Visit.vertex,Arr.t)
    for t, vis in qVisits.all():
        G.add_node(t,visits=list(vis))

# -------------------------------------------------------------------------------
# Print output
# -------------------------------------------------------------------------------
def print_output(fb):
    G = nx.DiGraph()
    add_visits(G,fb)
    print_nx_task_sequence(G,fb)

# -------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------

def main(ctrl_):
    unifier=[ Task, Path, Ass, TSeq, Move, Visit, Arr ]
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
        print_output(fb)

#    sys.stderr.flush()
#    sys.stdout.flush()

#end.
