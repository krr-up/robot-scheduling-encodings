#script(python)

from clorm import make_function_asp_callable, StringField, ConstantField, IntegerField, RawField, Raw, simple_predicate
from clorm.clingo import Control

scale=None
base=18.0
@make_function_asp_callable(IntegerField, IntegerField, StringField)
def register_grid(x: int, y: int) -> int:
    global scale
    maxval = max(x,y)
    scale = base/maxval
    return f"{scale}"

@make_function_asp_callable(IntegerField, IntegerField, StringField)
def xy_to_point(x: int, y: int) -> str:
    x = float(x)*scale
    y = float(y)*scale
    return f"{x},{y}"

@make_function_asp_callable(StringField, StringField)
def node_dim(dim: str) -> str:
    size = float(dim) * scale
    return f"{size}"

@make_function_asp_callable(RawField, RawField)
def node_name(rname: Raw) -> str:
    return rname
    return f"{rname}"

@make_function_asp_callable(RawField, StringField)
def robot_name(cname: Raw) -> str:
    return f"{cname}"

jobcount=1
nodes2job={}
@make_function_asp_callable(RawField, RawField, StringField)
def register_job(frm: Raw, to: Raw) -> str:
    global jobcount,nodes2job

    job = nodes2job.get((frm,to),None)
    if job is None:
       job = jobcount
       jobcount += 1
       nodes2job[(frm,to)] = job
    return f"jb{job}"


Node = simple_predicate("node",1)
Edge = simple_predicate("edge",1)
Attr = simple_predicate("attr", 4)
Bad = simple_predicate("bad", 2)
Scale = simple_predicate("scale", 1)
Bounds = simple_predicate("bounds", 2)
Grid = simple_predicate("grid", 2)

def main(ctrl_):
    unifier=[Node,Edge,Attr,Bad,Scale,Bounds,Grid]
#    unifier=[Node,Edge,Attr]
#    unifier=[Scale,Bounds,Grid]
    ctrl = Control(control_=ctrl_, unifier=unifier)
    ctrl.ground([("base",[])])
    with ctrl.solve(yield_=True) as sh:
         for m in sh:
             fb = m.facts(atoms=True)
             print(f"{fb.asp_str(sorted=True)}")
             return

#end.

max_x(X) :- node(_,X,_), #false: node(_,X',_), X' > X.
max_y(Y) :- node(_,_,Y), #false: node(_,_,Y'), Y' > Y.
min_x(X) :- node(_,X,_), #false: node(_,X',_), X' < X.
min_y(Y) :- node(_,_,Y), #false: node(_,_,Y'), Y' < Y.

bounds(X'-X,Y'-Y) :- max_x(X'), min_x(X), max_y(Y'), min_y(Y).

scale(@register_grid(X,Y))   :- grid(X,Y).
scale(@register_grid(X,Y))   :- not grid(_,_), bounds(X,Y).
scaled                       :- scale(_).

bad(From,manipulator)   :- job(_,From,To,Rep), not poss_manipulator(From).
bad(To,storage)         :- job(_,From,To,Rep), not poss_storage(To).
bad(Rep,empty_pallet)   :- job(_,From,To,Rep), not poss_empty_pallet(Rep).
bad(Nid,robot_home)     :- home(_,Nid), not poss_home(Nid).


deliver((T,T'),Nid, Nid') :- task(T,Nid), task(T',Nid'), depends(deliver,T,T').

job(@register_job(@node_name(From),@node_name(To)),From,To,Rep) :-
                   deliver((TM,TM'),From,To), deliver((TR,TR'),Rep,From),
                   depends(wait, TM, TR').

deliver(From,To)  :- job(_,From,To,Rep).
deliver(Rep,From)  :- job(_,From,To,Rep).

edge((@node_name(From),@node_name(To)))                            :- job(_,From,To,Rep).
edge((@node_name(Rep),@node_name(From)))                           :- job(_,From,To,Rep).
attr(edge, (@node_name(From),@node_name(To)), color, blue)         :- job(_,From,To,Rep).
attr(edge, (@node_name(Rep),@node_name(From)), color, red)         :- job(_,From,To,Rep).
attr(edge, (@node_name(Nid),@node_name(Nid')), style, "dashed")    :- deliver(Nid,Nid').
attr(edge, (@node_name(Nid),@node_name(Nid')), arrowsize, "1.0")   :- deliver(Nid,Nid').
attr(edge, (@node_name(Nid),@node_name(Nid')), splines, true)      :- deliver(Nid,Nid').
attr(edge, (@node_name(Nid),@node_name(Nid')), dir, forward)       :- deliver(Nid,Nid').



attr(graph_nodes, default, pin, true).
attr(graph_nodes, default, fixedsize, true).

node(@node_name(Nid))                                  :- node(Nid,_,_).
attr(node, @node_name(Nid), pos, @xy_to_point(X,Y))    :- node(Nid,X,Y), scaled.
edge((@node_name(From),@node_name(To)))                :- edge(From,To,_), From <= To.

node((X,Y),X*5000,Y*5000)              :- edge((X,Y),_,_).
node((X,Y),X*5000,Y*5000)              :- edge(_,(X,Y),_).

:- edge((From,To)), edge((To,From)).
:- edge(From,To,_), not edge((From,To)), not edge((To,From)).

type(Nid,home)                  :- start(_,Nid), scaled.
type(From,manipulator)          :- job(Job,From,To,Rep), scaled.
type(To,storage)                :- job(Job,From,To,Rep), scaled.
type(Rep,empty_pallet)          :- job(Job,From,To,Rep), scaled.
attr(node,@node_name(From),label,Job)       :- job(Job,From,To,Rep), scaled.
attr(node,@node_name(To),label,Job)         :- job(Job,From,To,Rep), scaled.

noi(Nid) :- type(Nid,_), scaled.
noi(Nid) :- robot(Robot), start(Robot,Nid), scaled.
noi(Nid) :- robot(Robot), home(Robot,Nid), scaled.

attr(node,@node_name(Nid),shape,circle)                 :- robot(Robot), start(Robot,Nid).
attr(node,@node_name(Nid),color,green)                  :- robot(Robot), start(Robot,Nid).
attr(node,@node_name(Nid),style,filled)                 :- robot(Robot), start(Robot,Nid).
attr(node,@node_name(Nid),label,@robot_name(Robot))     :- robot(Robot), start(Robot,Nid).
attr(node,@node_name(Nid),height,@node_dim("1000"))     :- robot(Robot), start(Robot,Nid).

diff_home(Robot,Nid)                        :- robot(Robot), home(Robot,Nid),
                                               start(Robot,Nid'), Nid != Nid'.

attr(node,@node_name(Nid),shape,square)                 :- diff_home(Robot,Nid).
attr(node,@node_name(Nid),color,green)                  :- diff_home(Robot,Nid).
attr(node,@node_name(Nid),style,filled)                 :- diff_home(Robot,Nid).
attr(node,@node_name(Nid),label,@robot_name(Robot))     :- diff_home(Robot,Nid).
attr(node,@node_name(Nid),height,@node_dim("1000"))     :- diff_home(Robot,Nid).

attr(node,@node_name(Nid),shape,octagon)                :- type(Nid,empty_pallet).
attr(node,@node_name(Nid),color,red)                    :- type(Nid,empty_pallet).
attr(node,@node_name(Nid),style,filled)                 :- type(Nid,empty_pallet).
attr(node,@node_name(Nid),height,@node_dim("900"))     :- type(Nid,empty_pallet).
attr(node,@node_name(Nid),width,@node_dim("900"))      :- type(Nid,empty_pallet).
attr(node,@node_name(Nid),label," ")                     :- type(Nid,empty_pallet).

attr(node,@node_name(Nid),shape,square)                 :- type(Nid,manipulator).
attr(node,@node_name(Nid),color,red)                    :- type(Nid,manipulator).
attr(node,@node_name(Nid),style,filled)                 :- type(Nid,manipulator).
attr(node,@node_name(Nid),height,@node_dim("1000"))     :- type(Nid,manipulator).

attr(node,@node_name(Nid),shape,square)                 :- type(Nid,storage).
attr(node,@node_name(Nid),color,cyan)                   :- type(Nid,storage).
attr(node,@node_name(Nid),style,filled)                 :- type(Nid,storage).
attr(node,@node_name(Nid),height,@node_dim("1000"))     :- type(Nid,storage).

waypoint(Nid) :- node(Nid), scaled, not noi(Nid),
                 not poss_home(Nid), not poss_manipulator(Nid),
                 not poss_empty_pallet(Nid), not poss_storage(Nid).

attr(node,@node_name(Nid),shape,circle)                 :- waypoint(Nid).
attr(node,@node_name(Nid),label," ")                     :- waypoint(Nid).
attr(node,@node_name(Nid),style,filled)                 :- waypoint(Nid).
attr(node,@node_name(Nid),color,black)                  :- waypoint(Nid).
attr(node,@node_name(Nid),height,@node_dim("200"))       :- waypoint(Nid).

unused(Nid) :- node(Nid), not noi(Nid), not waypoint(Nid).

attr(node,@node_name(Nid),shape,square)                 :- unused(Nid).
attr(node,@node_name(Nid),style,filled)                 :- unused(Nid).
attr(node,@node_name(Nid),color,grey)                   :- unused(Nid).
attr(node,@node_name(Nid),height,@node_dim("500"))      :- unused(Nid).
attr(node,@node_name(Nid),label," ")                     :- unused(Nid).

#show.
