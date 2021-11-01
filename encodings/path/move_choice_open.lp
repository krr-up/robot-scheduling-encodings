% ------------------------------------------------------------------------------
% Choose a set of moves.
%
% Inputs: task/2, edge/3, robot/1, path/2.
%
% Outputs: move/3.
%
% Note: task/2, edge/3, robot/1 are all domain predicates. So this leads to
% choice rules that are independant of non-domain predicates. Hopefully, should
% be faster than making the choice rule dependent on path/2.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Generate a set of moves for each path. The path is acyclic and the start and
% end must match the expected start and end positions to satisfy the task.
% ------------------------------------------------------------------------------

0 { move(T,V,V') : edge(V,V',_) } 1 :- task(T,_), edge(V,_,_).
0 { move(T,V,V') : edge(V,V',_) } 1 :- task(T,_), edge(_,V',_).

0 { move(R,V,V') : edge(V,V',_) } 1 :- robot(R), edge(V,_,_).
0 { move(R,V,V') : edge(V,V',_) } 1 :- robot(R), edge(_,V',_).
:- robot(R), not path(R,_), move(R,_,_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

