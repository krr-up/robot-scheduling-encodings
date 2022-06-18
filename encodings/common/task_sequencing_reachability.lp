% ------------------------------------------------------------------------------
% Handle the generation of acyclic task sequences using a reachability
% encoding. Take into account task sequences resulting from by delivery
% dependencies as they are domain predicates.
%
% Input facts: task_sequence/2.
% ------------------------------------------------------------------------------

task_reachable(T)  :- task_sequence(T,_), not task_sequence(_,T).
task_reachable(T') :- task_reachable(T), task_sequence(T,T').
:- task_sequence(T,_), not task_reachable(T).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
