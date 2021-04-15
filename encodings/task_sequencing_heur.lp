% ------------------------------------------------------------------------------
% Domain heuristic for robot to task assignments. Simplest is that because the
% robot assignment affect the start and end location for each robot's sequence
% of paths, therefore the task assignment should be decided before path moves.
%
% Available facts: robot/1, tasks/2, task_sequence/2, assignment/2,
% same_robot/2.
% ------------------------------------------------------------------------------


#heuristic assigment(R,T) : robot(R), task(T,_).    [10,level]

% ------------------------------------------------------------------------------
%
% ------------------------------------------------------------------------------


{ assignment(R,T) : robot(R), task(T,_) }.

:- task(T,_), not assignment(_,T).
:- task(T,_), 2 { assignment(R,T) }.

0 { task_sequence(T,T') : task(T',_), T != T' } 1 :- task(T,_).

same_robot(T,T')  :- assignment(R,T), assignment(R,T'), T < T'.
:- task_sequence(T,T'), not same_robot(T,T'), not same_robot(T',T).
:- task_sequence(T',T), task_sequence(T'',T), T' < T''.
:- task(T,_), not task_sequence(T,_), not task_sequence(_,T).

:- robot(R), #count{ T : assignment(R,T), not task_sequence(_,T) } > 1.
:- assignment(R,_),
   #false : assignment(R,T), task_sequence(T,_), not task_sequence(_,T).

:- depends(deliver,T,T'), not task_sequence(T,T').
:- depends(deliver,T,T'), assignment(R,T), not assignment(R,T').
:- depends(deliver,T,T'), assignment(R,T'), not assignment(R,T).
