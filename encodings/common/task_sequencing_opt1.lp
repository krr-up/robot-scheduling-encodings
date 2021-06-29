% ------------------------------------------------------------------------------
% If we have the shortest path information then we can minimize the distance
% between tasks in a sequence.
% Input facts: task_sequence/2, assignment/2, shortest_path/4.
% ------------------------------------------------------------------------------

% Minimize the minimum distance between the non-deterministic tasks in a sequence.
%#minimize { N,T,T' : task_sequence(T,T'), depends(deliver,_,T), depends(deliver,T',_),
%                     task(T,V), task(T',V'), shortest_path(V,V',N,_)}.

% ------------------------------------------------------------------------------
% If we minimize the number of tasks assigned to anyone robot then maybe we get a
% better makespan?
% ------------------------------------------------------------------------------


assigned(R,C) :- C = #count{ T: assignment(R,T) }, robot(R).

#minimize { C : assigned(R,C) }.

%#minimize { 1@R,T : assignment(R,T) }.

