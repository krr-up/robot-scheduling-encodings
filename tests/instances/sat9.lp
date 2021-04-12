%------------------------------------------------------------------------------
%
% (r1:s)           (r2:s)
% (r1:e)           (r2:e)
%   w1 ----- w2 -----w3
%
% Two robot at home positions but only one pair of tasks and involves w3 so r1
%has nothing to do.
%------------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w3,15).

robot(r1). start(r1,w1). home(r1,w1).
robot(r2). start(r2,w3). home(r2,w3).

task(t1,w2). task(t2,w3).

depends(deliver,t1,t2).

%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL
