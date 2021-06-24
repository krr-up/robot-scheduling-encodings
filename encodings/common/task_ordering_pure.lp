% ------------------------------------------------------------------------------
% A pure ASP handling to generate proper task sequences that doesn't rely on the
% DL constraints. In particular: 1) a robot with an assignment can have only a
% single task sequence and it is guaranteed to be linear, 2) wait dependencies
% has satisfied (both within a single robot assignment and between robot
% assignments).
%
% Note: it is still possible for an set of orderings to be unsatisfiable but (I
% think) this is only possible if the robots can block each other within the
% warehouse graph. And this can only be determine by the routing.
%
% Assign a unique task number and then checks that the ordering of tasks is
% correct.
%
% Input facts: tasks/2, depends/2, task_sequence/2, assignment/2, same_robot/2.
% ------------------------------------------------------------------------------


% ------------------------------------------------------------------------------
% Note: task/2 is a domain predicate so we can safely assign the #count to a
% variable.
% ------------------------------------------------------------------------------

task_count(0..C) :- C = #count{ T : task(T,_) }.

1 { task_num(T,N) : task_count(N) } 1 :- task(T,_).

:- task_num(T,N), task_num(T',N), T < T'.

:- depends(_,T,T'), task_num(T,N), task_num(T',N'), N' < N.
:- task_sequence(T,T'), task_num(T,N), task_num(T',N'), N' < N.


%#show task_num/2.
%#show task_count/1.
%#show after/2.
%#show depends/3.
%#show assignment/2.

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
