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
% Use clingo #edge for cycle detection
%
% Input facts: tasks/2, depends/2, task_sequence/2, assignment/2, same_robot/2.
% ------------------------------------------------------------------------------

#edge(T,T') : task_sequence(T,T').
#edge(T,T') : depends(wait,T,T').


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
