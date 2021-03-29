% ------------------------------------------------------------------------------
% Common code for assigning tasks to robots and generating a sequence of tasks
% for each robot. See Definition 4(i) + Definition 5 of the formalisation.
%
% NOTE: Currently, this module does NOT handle the task dependencies. However,
% the delivery task dependency could/should be handled here since it is common
% to all encodings; whereas the other task dependencies are specific to how the
% walk/projection/path is encoded. But to make it match the formalisation of an
% "executable assignment" it may be better to keep all the task dependency
% checking together.
%
% Input facts: robot/1, tasks/2.
% Output facts: task_sequence/2, assignment/2.
% Auxilary output facts: same_robot/2.
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

% Redundant
%:- depends(deliver,T,T'), assignment(R,T), not assignment(R,T').
%:- depends(deliver,T,T'), assignment(R,T'), not assignment(R,T).
