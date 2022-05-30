% ------------------------------------------------------------------------------
% Handle the generation of acyclic task sequences using a reachability
% encoding. Take into account task sequences resulting from by delivery
% dependencies as they are domain predicates.
%
% Input facts: task_sequence/2.
% ------------------------------------------------------------------------------

task_seq_reachable(T)  :- task_sequence(T,_), not task_sequence(_,T).
task_seq_reachable(T') :- task_seq_reachable(T), depends(deliver,T,T').
task_seq_reachable(T') :- task_seq_reachable(T), task_sequence(T,T'), not depends(deliver,T,T').

:- task_sequence(_,T), not task_seq_reachable(T).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
