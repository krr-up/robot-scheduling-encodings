%------------------------------------------------------------------------------
% Satisfiable for the walk encoding but unsat for path/fast encodings because r1
% needs to first get out of the way of r2 before it can double back.
%
% (r2:s) --------> (r2:e)
%
%        (r1:s/e)
%   w1 ---- w2 ---- w3
%           |
%           w4
% -----------------------------------------------------------------------------
#include "graph_rules.lp".

edge(w1,w2,15).
edge(w2,w3,15).
edge(w2,w4,15).

robot(r1). start(r1,w2). home(r1,w2).
robot(r2). start(r2,w1). home(r2,w3).


%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL


#defined task_sequence/2.
#defined depends/3.
#defined assignment/2.
#defined task/2.
#defined walk/3.
