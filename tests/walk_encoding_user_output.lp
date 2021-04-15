% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import sys
import networkx as nx
from clorm import func, simple_predicate, alias, notin_, in_, ph1_
from clorm.clingo import Control
from common_data_model import Task, Assignment, TaskSequence
from walk_encoding_data_model import Walk, Proj, Arrive, Exit, DlArrive, DlExit

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
def print_nx_task_sequence(fb):
    qTSeq = fb.query(TSeq).select(TSeq.first,TSeq.second)
    qTask = fb.query(Task,Ass)\
              .join(Task.tid == Ass.tid)\
              .select(lambda t,a: (t.tid, {"robot" : a.rid, "vertex" : t.vertex}))
    G = nx.DiGraph()
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
        v,a=next(iter(sg.nodes.data()))
        r = a["robot"]
        tasks = [ (v,sg.nodes[v]["vertex"]) for v in nx.topological_sort(sg)]

# -------------------------------------------------------------------------------
# Print walk by robot
# -------------------------------------------------------------------------------

def print_walk(fb):
    qProjs = fb.query(Ass,Proj).join(Ass.tid == Proj.tid)\
                               .select(Ass.rid,Ass.tid,Proj.step)
    proj = { (r,s) : t for r,t,s in qProjs.all() }

    qWalks = fb.query(Walk,Arr,Exit)\
               .join(Walk.rid == Arr.a.rid, Walk.rid == Exit.e.rid,
                     Walk.step == Arr.a.step,Walk.step == Exit.e.step)\
               .order_by(Walk.rid,Walk.step).group_by()\
               .select(Walk.step,Walk.vertex,Arr.t,Exit.t)

    print("Walks:")
    for r, walk in qWalks.all():
        print("Robot: {}".format(r))
        for s,v,a,e in walk:
            tmp1 = "({},{},{})".format(v,a,e)
            tid = proj.get((r,s),None)
            tmp2 = ": {}".format(tid) if tid else ""
            print("\t{:<3}: {:<14} {}".format(s,tmp1,tmp2))


# -------------------------------------------------------------------------------
# Print output
# -------------------------------------------------------------------------------
def print_output(fb):
#    print("HERE: {}".format(fb.asp_str()))
    print_walk(fb)
    print_nx_task_sequence(fb)

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
        print_output(fb)

    sys.stderr.flush()
    sys.stdout.flush()

#end.
