% ------------------------------------------------------------------------------
% Domain heuristic for robot to task assignments. Trying a simple heuristic to
% determine the task assignment before other decisions. The reason is that the
% robot assignment affects the start and end location for each robot's sequence
% of paths, therefore the task assignment should be decided before path moves.
%
% Available facts: robot/1, tasks/2, task_sequence/2, assignment/2,
% same_robot/2.
% ------------------------------------------------------------------------------

% First assign the main delivery tasks - then prefer the associated replacement
% tasks to be assigned to a different robot from the delivery task.
%#heuristic assignment(R,T) : depends(wait,T,_), robot(R).            [3,sign]

%#heuristic assignment(R,T') : assignment(R,T), depends(wait,T,T').   [2,false]


% Prefer to sequence tasks that are close together

%#heuristic assignment(R,T') : assignment(R,T),
%                                 depends(deliver,T,_), depends(deliver,T',_),
%                                 T < T', task(T,V), task(T',V'),
%                                 shortest_path(V,V',N,_),
%                                 #false : depends(deliver,T'',_), T < T'',
%                                          shortest_path(V,V'',N',_),
%                                          N' < N.                    [3,sign]


%%%#heuristic task_sequence(T,T') : depends(deliver,_,T), task(T,V),
%%%                                 depends(deliver,T',_), task(T,V'), T != T',
%%%                                 depends(deliver,T'',_), task(T,V''), T != T'',
%%%                                 shortest_path(V,V',N',_),
%%%                                 shortest_path(V,V'',N'',_),
%%%                                 T != T'', N'' < N'.                       [3,false]
%%%

%%%#heuristic task_sequence(T,T') : task(T,V), depends(deliver,_,T),
%%%                                 task(T',V'), depends(deliver,T',_),
%%%                                 task(T'',V''), depends(deliver,T'',_),
%%%                                 T' != T'',
%%%                                 not depends(deliver,T',T),
%%%                                 not depends(deliver,T'',T),
%%%                                 shortest_path(V,V',N',_),
%%%                                 shortest_path(V,V'',N'',_),
%%%                                 N'' < N'.                              [3,false]
%%%


%%%#heuristic task_sequence(T,T') : task(T,V), depends(deliver,_,T),
%%%                                 task(T',V'), depends(deliver,T',_),
%%%                                 not depends(deliver,T',T),
%%%                                 shortest_path(V,V',N',_),
%%%                                 #false :  task(T'',V''),
%%%                                 depends(deliver,T'',_),
%%%                                 not depends(deliver,T'',T),
%%%                                 shortest_path(V,V'',N'',_),
%%%                                 N'' < N'.                              [3,sign]
%%%


%%%% If a putdown and pickup task are close then try to assign them to the same
%%%% robot.
%%%#heuristic assignment(R,T') :    assignment(R,T),
%%%                                 depends(deliver,T,T'), task(T',V'),
%%%                                 task(T'',V''), depends(deliver,T'',_), T != T'',
%%%                                 shortest_path(V',V'',N'',_),
%%%                                 #false :  task(T''',V'''),
%%%                                 depends(deliver,T''',_), T != T''',
%%%                                 shortest_path(V',V''',N''',_),
%%%                                 N''' < N''.                           [3,sign]
%%%

% Minimize the distance between tasks in a sequence.
#minimize { N,T,T' : task_sequence(T,T'), depends(deliver,_,T), depends(deliver,T',_),
                     task(T,V), task(T',V'), shortest_path(V,V',N,_)}.

%%%% Once you have the task robot assignment then decide on back-to-back putdown
%%%% and pickup tasks based on shortest distances.
%%%#heuristic task_sequence(T,T') : assignment(R,T), assignment(R,T'),
%%%                                 depends(deliver,_,T),depends(deliver,T',_),
%%%                                 task(T,V), task(T',V'),
%%%                                 shortest_path(V,V',N',_),
%%%                                 #false :  assignment(R,T''), task(T'',V''),
%%%                                 depends(deliver,T'',_),
%%%                                 shortest_path(V,V'',N'',_),
%%%                                 N'' < N'.                            [2,sign]
%%%


%%%
%%%#heuristic assignment(R,T') :    task(T,V), depends(deliver,_,T),
%%%                                 assignment(R,T),
%%%                                 task(T',V'), depends(deliver,T',_),
%%%                                 not depends(deliver,T',T),
%%%                                 shortest_path(V,V',N',_),
%%%                                 #false :  task(T'',V''),
%%%                                 depends(deliver,T'',_),
%%%                                 not depends(deliver,T'',T),
%%%                                 shortest_path(V,V'',N'',_),
%%%                                 N'' < N'.                              [3,true]
%%%
%%%


% Prefer robots to exclusively handle delivery or pallet replacement tasks
%#heuristic assignment(R,T') : assignment(R,T),
%                              depends(wait,T,_), depends(wait,_,T'). [2,false]
%#heuristic assignment(R,T') : assignment(R,T),
%                              depends(wait,_,T), depends(wait,T,_). [2,false]

%
% ------------------------------------------------------------------------------
% % Is it possible to express a fairness type properly such as tasks are evenly
% distributed between robots. Something that involves counting?
% ------------------------------------------------------------------------------

%assigned(R) :- assignment(R,T).
%:- robot(R), not assigned(R).
%#heuristic assigned(R) : robot(R). [2,true]
