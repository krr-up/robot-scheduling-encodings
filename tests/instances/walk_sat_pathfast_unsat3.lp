%------------------------------------------------------------------------------
% Testing that a specific solution is UNSAT.
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

% Timing restriction that is not satisfiable for the path encoding.

dl(arrive(r1,w3),45).
dl(arrive(r2,w2),44).
&diff{ Var - 0 } <= Value :- dl(Var,Value).
&diff{ 0 - Var } <= -Value :- dl(Var,Value).


%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL
#defined walk/3.

#defined task/2.
#defined depends/3.
#defined assignment/2.
#defined task_sequence/2.
