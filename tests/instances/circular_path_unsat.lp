%------------------------------------------------------------------------------
%
% Test that there are no secondary circular paths possible for the path
% encoding. I'm not sure if it is possible that if there is one "real" path from
% source to destination then there could be some other circular paths. So create
% to disconnected graphs and see if there grap where the robot is not located
% can have moves assigned to it.
%
%        b1
%       /  \
%      b2--b3         (r1:s,e) g1--g2--g3--g4
%
% task(t1,g1), task(t2,g4), depends(deliver,t1,t2)
%
%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(b1,b2,15). edge(b2,b3,15).  edge(b3,b1,15).  % The disconnected graph

edge(g1,g2,15). edge(g2,g3,15). edge(g3,g4,15).   % The graph with the robot

robot(r1). start(r1,g1). home(r1,g1).

task(t1,g1). task(t2,g4).

depends(deliver,t1,t2).

% For the path encoding try to generate a move on bad graph
#defined move/3.
bmove :- move(_,(b1;b2;b3),_), encoding(path).
:- encoding(path), not bmove.
