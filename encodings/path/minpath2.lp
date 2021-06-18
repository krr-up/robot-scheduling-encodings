% ------------------------------------------------------------------------------
% This is similiar to minpath.lp but we want to explicitly separate the minimum
% paths that are dependant only on domain predicates from those that require
% reasoning.
%
% If we have precomputed shortest path information (in the form of the
% shortest_path/4) then we can define the minimum path for each task-path
% object. path_minpath(P,V) states that V is on the minimum path for path P.
%
% Input: start/2, assignment/2, path/2, task_sequence/2, path_sequence/2,
%        shortest_path/4, depends/3.
% Output: path_minpath/2.
% ------------------------------------------------------------------------------


% The starting vertex of a path is always on the minimum path. Three cases:
% 1) robot with no assignments returning home, 2) first in the task sequence,
% 3) non-first path.

path_minpath_nd(R,V)   :- start(R,V), not assignment(R,_), path(R,_).
path_minpath_nd(T,V)   :- start(R,V), assignment(R,T),
                          not depends(deliver,_,T), not task_sequence(_,T).
path_minpath_nd(P',V)  :- path_sequence(P,P'), path(P,V),
                          not depends(deliver,P,P').

path_minpath_nd(P,V'') :- path_minpath_nd(P,V), path(P,V'),
                          shortest_path(V,V',_,V'').

path_minpath_d(T',V)  :- depends(deliver,T,T'), task(T,V).
path_minpath_d(T,V'') :- path_minpath_d(T,V), task(T,V'),
                         shortest_path(V,V',_,V'').

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

