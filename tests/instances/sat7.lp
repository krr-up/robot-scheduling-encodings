%------------------------------------------------------------------------------
%
% (r1:s) w1 --- w2
%
% Robot doing multiple tasks at the same node
%
% NOTE: this is a boundary case because it has the robot able to do two tasks at
% the same node, one directly after the other. It is not clear if this should be
% allowable, is it would not be allowable under the original DoraBot
% requirements (because new items can't be made available at occupied
% cells). One way to allow for this special case is with a 0-time reflexive edge
% in the graph.

%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).

%edge(w1,w1,0).
%edge(w2,w2,0).

robot(r1). start(r1,w1). home(r1,w1).

task(t1,w1). task(t2,w2).
task(t3,w2). task(t4,w1).

depends(deliver,t1,t2).
depends(deliver,t3,t4).

%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL
