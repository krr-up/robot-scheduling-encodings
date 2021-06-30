% ------------------------------------------------------------------------------
% An alternative task sequencing method that builds a partial ordering of tasks
% that is dependant on the task assignment and the dependencies. The ordering
% then determines the sequencing.
%
% Note: one potential advantage of this method over the original direct
% sequencing method is that it provides more structure and so we can potentially
% apply heuristics and/or optimisation to the ordering to generate better
% assignment/sequencing. For example, we can possibly create a better/fairer
% spread of tasks reducing the maximum task level. However, this is mainly
% useful if it results in a lower makespan of the final solution and I still
% haven't managed to achieve this.
%
% Input facts: tasks/2, depends/2, assignment/2, same_robot/2.
% Output: task_sequence/2.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Note: task/2 is a domain predicate so we can safely assign the #count to a
% variable.
% ------------------------------------------------------------------------------

task_count(C) :- C = #count{ T : task(T,_) }.
task_level(0..C) :- task_count(C).

1 { task_num(T,N) : task_level(N) } 1 :- task(T,_).

:- depends(_,T,T'), task_num(T,N), task_num(T',N'), N' <= N.

:- robot(R), task_level(N), #count{ T : assignment(R,T), task_num(T,N) } > 1.

task_sequence(T,T') :- depends(deliver,_,T), depends(deliver,T',_),
                       assignment(R,T), assignment(R,T'),
                       task_num(T,N), task_num(T',N'), N < N',
                       #false : depends(deliver,T'',_),
                                assignment(R,T''), task_num(T'',N''),
                                N < N'', N'' < N'.

task_sequence(T,T')     :- depends(deliver,T,T').

% Only one starting sequence per robot
:- robot(R), #count{ T : assignment(R,T), not task_sequence(_,T) } > 1.




% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

#show task_num/2.
%#show task_count/1.
%#show task_sequence/2.
