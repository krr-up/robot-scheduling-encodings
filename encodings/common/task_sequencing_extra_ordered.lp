% ------------------------------------------------------------------------------
% Using the alternative task sequencing to guarantee a proper sequence order.
% Maybe this allows us the best of both systems so that we can have hueristics
% to find good sequences.
%
% Input facts: tasks/2, depends/2, assignment/2.
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

:- task_sequence(T,T'), task_num(T,N), task_num(T',N'), N' <= N.

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

%%%%_tpo_seq(T,T') :- task_sequence(T,T').
%%%%_tpo_seq(T,T') :- depends(wait,T,T').
%%%%
%%%%#edge (T,T') : _tpo_seq(T,T').
%%%%
