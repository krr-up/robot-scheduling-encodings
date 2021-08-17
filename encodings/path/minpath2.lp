% ------------------------------------------------------------------------------
% This is similiar to minpath.lp but we explicitly separate the minimum paths
% that for putdown tasks, which are dependant only on domain predicates, from
% the pickup and return home paths, which are dependent on choices. For these
% second minimum paths we define a 3-arity domain-predicate minpath by tracking
% the to-from paths.  From this 3-arity minpath we can then define a non-domain
% minpath.
%
% Input: start/2, assignment/2, path/2, task_sequence/2, path_sequence/2,
%        shortest_path/4, depends/3.
% Output: path_minpath_d/2. path_minpath/3, path_minpath_nd/2.
% ------------------------------------------------------------------------------


% ------------------------------------------------------------------------------
% The domain predicate minimum paths can be defined for putdown tasks
% ------------------------------------------------------------------------------

path_minpath_d(T',V)    :- depends(deliver,T,T'), task(T,V).
path_minpath_d(T,V'')   :- path_minpath_d(T,V), task(T,V'),
                           shortest_path(V,V',_,V'').

% ------------------------------------------------------------------------------
% Domain predicate of possible minimum paths that tracks the to-from
% paths. Three cases: 1) a robot returning home, 2) a robot moving to the first
% assigned task, 3) a robot that's finished a putdown task and moving on to the
% next pickup task. For robots returning home there are two sub-cases: 1) they
% have no assignments, 2) they have finished their assigned tasks.
% ------------------------------------------------------------------------------

path_minpath(R,R,V)     :- start(R,V).
path_minpath(T,R,V)     :- robot(R), depends(deliver,_,T), task(T,V).
path_minpath(P,R,V'')   :- path_minpath(P,R,V), home(R,V'),
                           shortest_path(V,V',_,V'').
path_minpath(R,T,V)     :- start(R,V), depends(deliver,T,_).
path_minpath(T',T'',V') :- depends(deliver,T,T'), task(T',V'),
                           depends(deliver,T'',_), T != T''.
path_minpath(P,T,V'')   :- path_minpath(P,T,V), task(T,V'),
                           shortest_path(V,V',_,V'').


% ------------------------------------------------------------------------------
% From the (domain predicate) path_minpath/3 define a non-domain predicate
% path_minpath_nd/2. Four cases: 1) robot without assignments returning home, 2)
% robot with finished assignments returning home, 3) robot moving to first
% pickup task, 4) robot moving to subsequent pickup task.
% ------------------------------------------------------------------------------

path_minpath_nd(R,V)     :- path_minpath(R,R,V), not assignment(R,_), path(R,_).
path_minpath_nd(R,V)     :- path_minpath(T,R,V), path_sequence(T,R), not path_sequence(R,_).
path_minpath_nd(T,V)     :- path_minpath(R,T,V), assignment(R,T),
                            task_sequence(T,_), not task_sequence(_,T).
path_minpath_nd(T',V)    :- path_minpath(T,T',V), task_sequence(T,T'), task(T',_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

