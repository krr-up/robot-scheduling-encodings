% ------------------------------------------------------------------------------
% Solution checker.
% Produces: err/1.
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


err(missing_assignment(T))    :- task(T,_), not assignment(_,T).
err(missing_sequencing(T))    :- task(T,_), not task_sequence(T,_),
                                 not task_sequence(_,T).

err(multi_successor_tasks(T)) :- #count{ T' : task_sequence(T,T') } > 1, task(T,_).
err(multi_parent_tasks(T'))   :- #count{ T : task_sequence(T,T') } > 1, task(T',_).

err(bad_assignment(R,T,T'))   :- depends(deliver,T,T'), assignment(R,T),
                                 not assignment(R,T').
err(bad_assignment(R,T,T'))   :- depends(deliver,T,T'), assignment(R,T'),
                                 not assignment(R,T).
err(bad_delivery(T,T'))       :- depends(deliver,T,T'), not task_sequence(T,T').

% ------------------------------------------------------------------------------
% Check the walks of the robots to make sure that it satisfies the graph (edges
% and timing) and that the combined walks are collision free. Also make sure
% each walk ends at its robot's home location.
%
% Requires the following input facts:
%
% - Edges: edge(V1,V2,Weight).
% - Conflicts: conflict(e,(V1,V2),(V1',V2')), conflict(v,V,V').
% - Robot walks: walk(Robot,Step,Vertex,ArriveTime,ExitTime).
% - Robot home: home(R,V)
% - Robot start: start(R,V)
% ------------------------------------------------------------------------------

% Note: using -1 to indicate a walk step that never exits the vertex
twalk(R,S,V,A,E)      :- walk(R,S,V,A,E), E >=0.
twalk(R,S,V,A,#sup)   :- walk(R,S,V,A,E), E < 0.


err(noedge(R,S,V,V'))               :- twalk(R,S,V,A,E), twalk(R,S+1,V',A',E'),
                                       not edge(V,V',_).

err(timing(R,S,V,V',A'-E))          :- twalk(R,S,V,A,E), twalk(R,S+1,V',A',E'),
                                       edge(V,V',W), A'-E < W.

err(conflict(v,(R,S,V),(R',S',V'))) :- twalk(R,S,V,A,Ex), twalk(R',S',V',A',Ex'), R != R',
                                       conflict(v,V,V'), A <= A', Ex >= Ex'.

err(conflict(e,(R,S,E),(R',S',E'))) :- twalk(R,S,V1,A1,Ex1), twalk(R,S+1,V2,A2,Ex2),
                                       twalk(R',S',V1',A1',Ex1'), twalk(R',S'+1,V2',A2',Ex2'),
                                       E=(V1,V2), E'=(V1',V2'), R != R',
                                       conflict(e,E,E'), Ex1 <= Ex1', A2 >= A2'.

err(nothoming(R)) :- start(R,V), not home(R,V), not walk(R,_,_,_,_).
err(nothoming(R)) :- walk(R,S,V,_,_), not walk(R,S+1,_,_,_), not home(R,V).

% ------------------------------------------------------------------------------
% Check the actions for each task. Also checks the timing for any dependencies
% between tasks.
%
% Requires the following input facts:
% - action(Task,Vertex,StartTime,EndTime)
% - task(Task,Vertex)
% - depends(Type,Task1,Task2)
% ------------------------------------------------------------------------------
#const epsilon=10.

err(unknown_action(T,V,S,E))             :- action(T,V,S,E), not task(T,V).
err(missing_task_action(T,V))            :- task(T,V), not action(T,V,_,_).
err(bad_task_timing(T,E-S))              :- action(T,_,S,E), E-S < epsilon.
err(bad_task_dependency((T,E),(T',S')))  :- action(T,V,S,E), action(T',V',S',E'),
                                            depends(_,T,T'), S' < E.

% ------------------------------------------------------------------------------
% Check that the action generation matches the walk for the robot.
% - assignment(Robot,Task)
% - Robot walks: walk(Robot,Step,Vertex,ArriveTime,ExitTime).
% - action(Task,Vertex,StartTime,EndTime)
% ------------------------------------------------------------------------------
err(bad_walk_action(R,T,V,S,E))   :- action(T,V,S,E), assignment(R,T),
                                     #false : twalk(R,_,V,S',E'), S' <= S, E <= E'.

% ------------------------------------------------------------------------------
% If no errors than we're ok
% ------------------------------------------------------------------------------

noerrors :- not err(_).

% ------------------------------------------------------------------------------
% Output
% ------------------------------------------------------------------------------

walk_length(R,S) :- walk(R,S,_,_,_), not walk(R,S+1,_,_,_).

#show.
#show noerrors/0.
#show err/1.
#show walk_length/2.
#show dl(bound,B) : dl(bound,B).
#defined action/4.


#defined task/2.
#defined depends/3.
#defined assignment/2.
#defined task_sequence/2.
