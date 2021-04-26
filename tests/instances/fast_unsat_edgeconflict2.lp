%------------------------------------------------------------------------------
%
% Because of the edge conflict r1 must arrive at w2 before r2 leaves w4. But
% because we only track arrival times (and not exit times) for the fast encoding
% the closest we can get to this is to specify is that r1 must arrive at w2
% before r2 arrives at w4. But since r2 starts at w4 this is not possible so is
% unsatisfiable.
%
%       <---------
% (r1:e) w2
%         \     (r1:s)   (r2:e)
%         w5 --- w6 ---- w7
%         /
% (r2:s) w4
%       ---------------->
%
% Conflict edge (w2,w4) and (w4,w5)
%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w2,w5,15).
edge(w4,w5,15). edge(w5,w6,15). edge(w6,w7,15).

robot(r1). start(r1,w6). home(r1,w2).
robot(r2). start(r2,w4). home(r2,w7).

conflict(e,(w2,w5),(w4,w5)).


%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL

#defined task/2.
#defined depends/3.
