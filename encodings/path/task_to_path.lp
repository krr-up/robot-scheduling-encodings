% ------------------------------------------------------------------------------
% A walk consists of a sequence of paths for a robot; there must be a path for
% each task as well as a return home path for each robot that is not already
% home or has assignments.
%
% Input: task/2, assignment/2, home/2, start/2, task_sequence/2.
%
% Output: path/2, path_sequence/2, path_assignment/2.
%
% ------------------------------------------------------------------------------

path(T,V)             :- task(T,V).
path(R,V)             :- assignment(R,_), home(R,V).
path(R,V)             :- home(R,V), not start(R,V).

path_sequence(T,T')   :- task_sequence(T,T').
%path_sequence(T,R)    :- task_sequence(_,T), not task_sequence(T,_), assignment(R,T).
%path_sequence(T,R)    :- assignment(R,T), not task_sequence(_,T), not task_sequence(T,_).

path_sequence(T,R)    :- assignment(R,T), not task_sequence(T,_).

path_assignment(R,T)  :- assignment(R,T).
path_assignment(R,R)  :- assignment(R,_).
path_assignment(R,R)  :- home(R,V), not start(R,V).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

