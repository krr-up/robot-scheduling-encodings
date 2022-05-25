% ------------------------------------------------------------------------------
% A pure ASP handling to generate proper task sequences that doesn't rely on the
% DL constraints. In particular: a robot with an assignment can have only a
% single task sequence and it is guaranteed to be linear.
%
% NOTE: this constraint is redundant when the DL timing constraints are added.
%
% Use clingo #edge for cycle detection
%
% Input facts: task_sequence/2.
% ------------------------------------------------------------------------------

#edge(T,T') : task_sequence(T,T').


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
