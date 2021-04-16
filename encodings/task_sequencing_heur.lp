% ------------------------------------------------------------------------------
% Domain heuristic for robot to task assignments. Trying a simple heuristic to
% determine the task assignment before other decisions. The reason is that the
% robot assignment affects the start and end location for each robot's sequence
% of paths, therefore the task assignment should be decided before path moves.
%
% Available facts: robot/1, tasks/2, task_sequence/2, assignment/2,
% same_robot/2.
% ------------------------------------------------------------------------------

#heuristic assignment(R,T). [10,level]

% ------------------------------------------------------------------------------
%
% ------------------------------------------------------------------------------

