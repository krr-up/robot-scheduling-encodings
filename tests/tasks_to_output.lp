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

class FirstTask(Predicate):
    rid=RawField
    tid=RawField
    class Meta: name="first_task"

class Depends(Predicate):
    dtype=ConstantField
    tid1=RawField
    tid2=RawField

class TaskNum(Predicate):
    tid=RawField
    num=IntegerField
    class Meta: name="task_num"

class Robot(Predicate):
    rid=RawField

Ass=Assignment
TSeq=TaskSequence
TNum=TaskNum
FTsk=FirstTask

# -------------------------------------------------------------------------------
# Print the task sequences for each robot
# -------------------------------------------------------------------------------

g_robots="false"

def build_task_graph(fb):
    global g_robots
    G=nx.DiGraph()
    qRobot = fb.query(Robot).select(lambda r : str(r.rid))
    qAss   = fb.query(Ass).select(lambda a: (str(a.rid),str(a.tid)))
    qFTsk   = fb.query(FTsk).select(lambda ft: (str(ft.rid),str(ft.tid)))
    qTasks = fb.query(Task).select(lambda t: str(t.tid))
    qWaits = fb.query(Depends).where(Depends.dtype == "wait")\
                              .select(lambda d: (str(d.tid1),str(d.tid2)))
    qDels  = fb.query(Depends).where(Depends.dtype == "deliver")\
                              .select(lambda d: (str(d.tid1),str(d.tid2)))
    qTSeqs = fb.query(TSeq)\
               .where(notin_(path(TSeq),
                             fb.query(Depends).where(Depends.dtype == "deliver")))\
               .select(lambda ts: (str(ts.tid1),str(ts.tid2)))

    G.add_nodes_from(list(qRobot.all()),color="green")
    G.add_nodes_from(list(qTasks.all()),color="blue")
    G.add_edges_from(list(qTSeqs.all()),color="black",label="next",width=4)
    G.add_edges_from(list(qDels.all()),weight=1.0,color="grey",label="deliver",width=4)
    G.add_edges_from(list(qWaits.all()),color="green",label="wait",width=2)

    if g_robots != "true": tmp = list(qFTsk.all())
    else: tmp = list(qAss.all())
    G.add_edges_from(tmp,weight=1.0,color="cyan",label="assignment",width=1)
    return G

def show_task_graph(fb):
    G = build_task_graph(fb)
    pos = nx.nx_agraph.graphviz_layout(G, prog="dot")

    nodes = G.nodes()
    ncolors = [ G.nodes[u]['color'] for u in nodes]
    edges = G.edges()
    ecolors = [ G.edges[u,v]['color'] for u,v in edges]
    widths = [ G.edges[u,v]['width'] for u,v in edges]

#    nx.draw(G,pos,nodes=nodes,node_color=ncolors,
#            edges=edges,edge_color=ecolors,width=widths,with_labels=True)
    nx.draw(G,pos,node_color=ncolors,
            edge_color=ecolors,width=widths,with_labels=True)
    plt.show()

# -------------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------------

def main(ctrl_):
    global g_robots
    unifier=[Task,Ass,FTsk,TSeq,Depends,TNum,Robot]
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

% ----------------------------------------------------------------------------
% Work out the first task for a robot
% ----------------------------------------------------------------------------

first_task(R,T) :- robot(R), assignment(R,T), not task_sequence(_,T).

% ----------------------------------------------------------------------------
%
% ----------------------------------------------------------------------------

#show.
