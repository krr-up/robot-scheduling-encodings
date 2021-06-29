% ------------------------------------------------------------------------------
% Heuristic to improve the pure ASP task sequencing that assigns a level number
% to each task.

% Input facts: tasks/2, depends/2, task_sequence/2, assignment/2, same_robot/2,
%              task_num/2, task_count/1, task_level/1.
% ------------------------------------------------------------------------------

% Prefer lower task num assignments so that we get fewer levels which will
% hopefully result in an even spread.

%#heuristic task_num(T,N) : task_num(T,N), task_count(C).           [C-N+3,true]
%#heuristic task_num(T,N) : task_num(T,N), task_count(C).           [1,sign]

%#heuristic task_num(T,N) : task_num(T,N), task_count(C),
%                           task_level(N'), N' > N.                 [C-N+2,false]



% ------------------------------------------------------------------------------
% Optimise on some properties to understand what a good allocation might look like
% ------------------------------------------------------------------------------


%%%%maxlevel(N) :- task_num(_,N), #false : task_num(_,N'), N' > N.
%%%%#minimize{ N@1 : maxlevel(N) }.
%%%%
%%%%#maximize{ N'-N,T,T' : task_num(T,N), task_num(T',N'), depends(wait,T,T') }.
%%%%
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------



% Want to get a good spread of tasks so reduce the number of task levels

#heuristic task_num(T,N) : task_level(N), task_count(C), depends(deliver,T,_). [C-N,factor]


% Want to minimise distance when moving from a putdown task to the next pickup
% task Note: the independence of tasks here doesn't/can't take into account when
% the path of one task blocks the path of another. For this we have to consider
% the route. This may be bad for randomly generated instances???
_indp_tasks(T,T',N) :- task(T,V), task(T',V'), shortest_path(V,V',N,_),
                       depends(deliver,_,T), depends(deliver,T',_),
                       not depends(deliver,T',T), not depends(wait,T,T').

_indp_count(C) :- C = #count{ N : _indp_tasks(T,T',N) }.

_indp_level(0,N)    :- _indp_tasks(_,_,N), #false: _indp_tasks(_,_,N'), N' < N.
_indp_level(I+1,N') :- _indp_level(I,N), _indp_tasks(_,_,N'), N' > N,
                       #false: _indp_tasks(_,_,N''), N < N'', N'' < N'.


#heuristic task_sequence(T,T') : _indp_tasks(T,T',N),
                                 _indp_count(C), _indp_level(I,N).  [C-I,factor]
