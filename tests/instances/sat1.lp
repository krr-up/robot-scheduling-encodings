%------------------------------------------------------------------------------
% Sat with only one possible ordering of walks
%
%          (r1:s) ------> (r1:e)
%   w1 ---- w2 ---- w3 ---- w4
% (r2:s) -------> (r2:s)
%
% -----------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w3,15).
edge(w3,w4,15).

robot(r1). start(r1,w2). home(r1,w4).
robot(r2). start(r2,w1). home(r2,w3).


%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL

%:- not before(e,(r1,0),(r2,1)).


#defined task_sequence/2.
#defined depends/3.
#defined assignment/2.
#defined task/2.
#defined walk/3.
