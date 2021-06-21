% ------------------------------------------------------------------------------
% If we have the shortest path information then we can minimize the distance
% between tasks in a sequence.
% Input facts: task_sequence/2, assignment/2, shortest_path/4.
% ------------------------------------------------------------------------------

% Minimize the distance between tasks in a sequence.
#minimize { N,T,T' : task_sequence(T,T'), depends(deliver,_,T), depends(deliver,T',_),
                     task(T,V), task(T',V'), shortest_path(V,V',N,_)}.

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
