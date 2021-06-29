% ----------------------------------------------------------------------------
% Python wrapper for output
% ----------------------------------------------------------------------------

#script(python)
import sys
import networkx as nx
import matplotlib.pyplot as plt
from clorm import func, simple_predicate, alias, notin_, in_, ph1_, ph2_, notin_, in_, path
from clorm import Predicate, ConstantField, StringField, IntegerField, RawField
from clorm.clingo import Control

class Task(Predicate):
    tid=RawField
    vertex=RawField

class Assignment(Predicate):
    rid=RawField
    tid=RawField

class TaskSequence(Predicate):
    tid1=RawField
    tid2=RawField
    class Meta: name="task_sequence"

class Depends(Predicate):
    dtype=ConstantField
    tid1=RawField
    tid2=RawField

class TaskNum(Predicate):
    tid=RawField
    num=IntegerField
    class Meta: name="task_num"

Ass=Assignment
TSeq=TaskSequence
TNum=TaskNum


# -------------------------------------------------------------------------------
# Print the task sequences for each robot
# -------------------------------------------------------------------------------

g_robots="false"

def build_task_graph(fb):
    global g_robots
    G=nx.DiGraph()
    qAss   = fb.query(Ass).select(Ass.rid,Ass.tid)
    qTasks = fb.query(Task).select(Task.tid)
    qWaits = fb.query(Depends).where(Depends.dtype == "wait")\
                              .select(Depends.tid1,Depends.tid2)
    qDels  = fb.query(Depends).where(Depends.dtype == "deliver")\
                              .select(Depends.tid1,Depends.tid2)
    tmp = [TSeq(tid1,tid2) for tid1,tid2 in qDels.all()]
    qTSeqs = fb.query(TSeq).where(notin_(path(TSeq), tmp))

    G.add_nodes_from([str(n) for n in list(qTasks.all())])
    G.add_edges_from(
        [(str(n1),str(n2)) for n1,n2 in list(qTSeqs.all())],
        color="green",label="next",width=4)
    G.add_edges_from(
        [(str(n1),str(n2)) for n1,n2 in list(qDels.all())],
        weight=1.0,color="blue",label="deliver",width=4)
    G.add_edges_from(
        [(str(n1),str(n2)) for n1,n2 in list(qWaits.all())],
        color="red",label="wait",width=1)

    if g_robots != "true": return G
    G.add_edges_from(
        [(str(n1),str(n2)) for n1,n2 in list(qAss.all())],
        weight=1.0,color="yellow",label="assignment",width=1)
    return G

def show_task_graph(fb):
    G = build_task_graph(fb)
    pos = nx.nx_agraph.graphviz_layout(G, prog="dot")

    edges = G.edges()
#    edges = [ (u,v) for u,v in G.edges if G[u][v]['label'] == "next"]
    colors = [ G[u][v]['color'] for u,v in edges]
    widths = [ G[u][v]['width'] for u,v in edges]
#    weights = [ G[u][v]['weight'] for u,v in edges]

    nx.draw(G,pos,edges=edges,edge_color=colors,width=widths,with_labels=True)
    plt.show()

# -------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------

def main(ctrl_):
    global g_robots
    unifier=[Task,Ass,TSeq,Depends,TNum]
    ctrl=Control(control_=ctrl_,unifier=unifier)

    robots = ctrl.get_const("robots")
    if robots is not None:
        g_robots=str(robots)

#    ctrl.configuration.solve.quiet = 2
    opt_mode = str(ctrl.configuration.solve.opt_mode)

    ctrl.ground([("base",[])])

    fb=None
    with ctrl.solve(yield_=True) as sh:
        for model in sh:
            fb = model.facts(atoms=True)
            if opt_mode == "optN" and model.optimality_proven:
                show_task_graph(fb)

    if fb is None:
        raise SystemError("Unsatisfiable")
    if opt_mode != "optN":
        show_task_graph(fb)

    sys.stderr.flush()
    sys.stdout.flush()

#end.
#show.
