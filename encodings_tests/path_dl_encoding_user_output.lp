% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import itertools
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
# Global variables
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
# Print the task sequence by robot
# -------------------------------------------------------------------------------
def print_nx_task_sequence(G,fb):
    qTSeq = fb.query(TSeq).select(TSeq.first,TSeq.second)
    qTask = fb.query(Task,Ass)\
              .join(Task.tid == Ass.tid)\
              .select(lambda t,a: (t.tid, {"robot" : a.rid, "vertex" : t.vertex}))
    G.add_nodes_from(qTask.all())
    G.add_edges_from(qTSeq.all())

    # Make sure there are no cycles
    if not nx.is_directed_acyclic_graph(G):
        print("NOT A DAG")
        return
    # Get the weakly connected components - each subgraph will be the tasks for
    # a single robot
    print("Task sequences:")
    for c in nx.weakly_connected_components(G):
        sg = G.subgraph(c)
        t,a=next(iter(sg.nodes.data()))
        r = a["robot"]
        print("Robot {}:".format(r))
        for t in nx.topological_sort(sg):
            print("\tTask {}".format(t))
            for visit in sg.nodes[t]["visits"]:
                print("\t\t({},{},{})".format(*visit))
    return G

# -------------------------------------------------------------------------------
# Print moves by robot

# FIXUP: THERE IS A BUG IN THE QUERY SORT. SO SORT MANUALLY TILL I FIX IT
# -------------------------------------------------------------------------------

def print_visits(G,fb):
    qVisits = fb.query(Visit,Arr,Exit)\
                .join(Visit.tid == Arr.a.tid, Visit.tid == Exit.e.tid,
                      Visit.vertex == Arr.a.vertex,
                      Visit.vertex == Exit.e.vertex)\
                .order_by(Visit.tid, Arr.t)\
                .select(Visit.tid,Visit.vertex,Arr.t,Exit.t)

    visits = list(qVisits.all())
    visits.sort(key=lambda x: (x[0],x[2]))
    for t, vis in itertools.groupby(visits, lambda x: x[0]):
        tmp = [ (x[1],x[2],x[3]) for x in vis]
        G.add_node(t,visits=tmp)


#    for t, visits in qVisits.all():
#        vlist = list(visits)
#        print("VISITS: {}: {}".format(t, vlist))
#        G.add_node(t,visits=vlist)

# -------------------------------------------------------------------------------
# Print output
# -------------------------------------------------------------------------------
def print_output(fb):
    G = nx.DiGraph()
    print_visits(G,fb)
    print_nx_task_sequence(G,fb)

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
        print_output(fb)
#end.
