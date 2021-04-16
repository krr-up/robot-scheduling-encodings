% ------------------------------------------------------------------------------
% Common code for assigning tasks to robots and generating a sequence of tasks
% for each robot. See Definition 4(i) + Definition 5 of the formalisation.
%
% Input facts: robot/1, tasks/2.
% Output facts: task_sequence/2, assignment/2.
% Auxilary output facts: same_robot/2.
% ------------------------------------------------------------------------------







% ------------------------------------------------------------------------------
% Choose the assignment of robots to tasks and the task_sequences
% ------------------------------------------------------------------------------

1 { assignment(R,T) : robot(R) } 1 :- task(T,_).

:- depends(deliver,T,T'), assignment(R,T), not assignment(R,T').
:- depends(deliver,T,T'), assignment(R,T'), not assignment(R,T).

0 { task_sequence(T,T') : task(T',_), T != T' } 1 :- task(T,_).

:- depends(deliver,T,T'), not task_sequence(T,T').

% ------------------------------------------------------------------------------
% Make sure the assignment and task sequences are correct
% ------------------------------------------------------------------------------

same_robot(T,T')  :- assignment(R,T), assignment(R,T'), T < T'.
:- task_sequence(T,T'), not same_robot(T,T'), not same_robot(T',T).
:- task_sequence(T',T), task_sequence(T'',T), T' < T''.
:- task(T,_), not task_sequence(T,_), not task_sequence(_,T).

:- robot(R), #count{ T : assignment(R,T), not task_sequence(_,T) } > 1.
:- assignment(R,_),
   #false : assignment(R,T), task_sequence(T,_), not task_sequence(_,T).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

#show.

#show assignment/2.
#show task_sequence/2.






