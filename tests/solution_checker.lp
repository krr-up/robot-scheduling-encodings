% ------------------------------------------------------------------------------
% Solution checker.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Check the task assignment; the dependency between delivery tasks are met and
% the assigned task sequences don't have errors (cycles).
%
% Requires the following input facts:
% - Dependency: depends(Type,Task1,Task2)
% - Assignment: assignment(Robot,Task)
% - Task Sequence:  task_sequence(T,T')
% - Tasks: task(Task,Vertex)
% ------------------------------------------------------------------------------

missing_assignment(T)      :- task(T,_), not assignment(_,T).
missing_sequencing(T)      :- task(T,_), not task_sequence(T,_),
                              not task_sequence(_,T).

multi_successor_tasks(T)   :- #count{ T' : task_sequence(T,T') } > 1, task(T,_).
multi_parent_tasks(T')     :- #count{ T : task_sequence(T,T') } > 1, task(T',_).

bad_assignment(R,T,T')     :- depends(deliver,T,T'), assignment(R,T),
                              not assignment(R,T').
bad_assignment(R,T,T')     :- depends(deliver,T,T'), assignment(R,T'),
                              not assignment(R,T).
bad_delivery(T,T')         :- depends(deliver,T,T'), not task_sequence(T,T').

% ------------------------------------------------------------------------------
% The the walks of the robots to make sure that it satisfies the graph (edges
% and timing) and that the combined walks are collision free.
%
% Requires the following input facts:
%
% - Edges: edge(V1,V2,Weight).
% - Conflicts: conflict(e,(V1,V2),(V1',V2')), conflict(v,V,V').
% - Robot walks: walk(Robot,Step,Vertex,ArriveTime,ExitTime).
% ------------------------------------------------------------------------------

noedge(R,S,V,V')           :- walk(R,S,V,A,E), walk(R,S+1,V',A',E'),
                               not edge(V,V',_).

mistimed(R,S,V,V',E'-E)    :- walk(R,S,V,A,E), walk(R,S+1,V',A',E'),
                              edge(V,V',W), E'-E < W.

conflicted(v,(R,S,V),(R',S',V')) :- walk(R,S,V,A,Ex), walk(R',S',V',A',Ex'), R != R',
                                    conflict(v,V,V'), A <= A', Ex >= Ex'.

conflicted(e,(R,S,E),(R',S',E')) :- walk(R,S,V,A,Ex), walk(R,S+1,V2,A2,Ex2),
                                    walk(R',S',V',A',Ex'), walk(R',S'+1,V2',A2',Ex2'),
                                    E=(V,V2), E'=(V',V2'), R != R',
                                    conflict(e,(V,V2),(V',V2')), Ex <= Ex', A2 >= A2'.

% ------------------------------------------------------------------------------
% Check the actions for each task.
%
% Requires the following input facts:
% - action(Task,Vertex,StartTime,EndTime)
% - task(Task,Vertex)
% ------------------------------------------------------------------------------
#const epsilon=10.

bad_task_vertex(T,V)   :- action(T,V,_,_), not task(T,V).
bad_task_timing(T,E-S) :- action(T,_,S,E), E-S < epsilon.

% ------------------------------------------------------------------------------
% Output
% ------------------------------------------------------------------------------

#show.

#show missing_assignment/1.
#show missing_sequencing/1.
#show multi_successor_tasks/1.
#show multi_parent_tasks/1.
#show bad_assignment/3.
#show bad_delivery/2.

#show noedge/4.
#show mistimed/5.
#show conflicted/3.

#show bad_task_vertex/2.
#show bad_task_timing/2.
