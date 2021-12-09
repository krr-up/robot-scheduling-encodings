% ------------------------------------------------------------------------------
% If we have precomputed shortest path information (in the form of the
% shortest_path/4) then we can define the minimum path for each task-path
% object. path_minpath(P,V) states that V is on the minimum path for path P.
%
% Input: start/2, assignment/2, path/2, task_sequence/2, path_sequence/2,
%        shortest_path/4.
% Output: path_minpath/2.
% ------------------------------------------------------------------------------


% The starting vertex of a path is always on the minimum path. Three cases:
% 1) robot with no assignments returning home, 2) first in the task sequence,
% 3) non-first path.

path_minpath(R,V)   :- start(R,V), not assignment(R,_), path(R,_).
path_minpath(T,V)   :- start(R,V), assignment(R,T), not task_sequence(_,T).
path_minpath(P',V)  :- path_sequence(P,P'), path(P,V).

path_minpath(P,V'') :- path_minpath(P,V), path(P,V'),
                       shortest_path(V,V',_,V'').

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

