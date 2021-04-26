% ------------------------------------------------------------------------------
% Extra constraints that reduce the space of solutions - either to produce
% better quality solutions of to improve performance.
% ------------------------------------------------------------------------------

% Make the transition time between the end of one task and the start of the next
% path exactly epislon. Note: not neccessary for correctness but does it help
% with solving? Maybe solving if problem is UNSAT?


%% &diff{ arrive(P',V) - arrive(P,V) } <= epsilon  :- path(P,V), path_sequence(P,P').


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

