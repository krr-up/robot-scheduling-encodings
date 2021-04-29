% ------------------------------------------------------------------------------
% Choose a set of moves.
%
% Inputs: edge/3, path/2.
%
% Outputs: move/3.

% Note: path/2 is not a domain predicate, so the choice rule is more complex.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Generate a set of moves for each path. The path is acyclic and the start and
% end must match the expected start and end positions to satisfy the task.
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_) } 1 :- path(P,_), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_) } 1 :- path(P,_), edge(V',_,_).


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

