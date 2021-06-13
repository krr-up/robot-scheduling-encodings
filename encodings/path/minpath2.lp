% ------------------------------------------------------------------------------
% If we have precomputed shortest path information (in the form of the
% shortest_path/4 predicate) then we can track the minimum path for each
% task-path object.
%
% path_minpath(P,Src,Via) - for the robot executing the path P, if it is currently
% at Src then Via is on the minimum path to the destination for P.
%
% This can be combined with domain heuristics for improving move selection based
% on the shortest path.
%
% Input: start/2, path_sequence/2, path/2, shortest_path/4.
% Output: on_minpath/3.
%
% Note: start/2, path/2, shortest_path/4 are domain predicates
% ------------------------------------------------------------------------------

path_minpath(R,Src,V)     :- start(R,Src), not path_sequence(_,R), path(R,Dest),
                             shortest_path(Src,Dest,_,V).
path_minpath(P',Src,V)    :- path_sequence(P,P'), path(P,Src), path(P',Dest),
                             shortest_path(Src,Dest,_,V).
path_minpath(P,Src,V)     :- path_minpath(P,_,Src), path(P,Dest),
                             shortest_path(Src,Dest,_,V).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
