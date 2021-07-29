% ------------------------------------------------------------------------------
% If we have the shortest path information then we can calculate the mimimum
% distance between the destinations for path_sequences.
% Note: path_sequences that derive from depends(deliver,T,T')
% are domain predicates so their minimum distance will also be a domain
% predicate.
%
% Input facts: shortest_path(Src,Dest,N,Next), path(T,V), task(T,V).
%              depends(deliver,T,T'), path_sequence(P,P'), task_sequence(T,T').
%
% Output: sets dl constraints
%
% ------------------------------------------------------------------------------

% Robot with no assignments returning home
&diff{ arrive(R,V) - arrive(R,V') } <= -N :-
                                   start(R,V), home(R,V'), V != V',
                                   not assignment(R,_), shortest_path(V,V',N,_).

% First in the task sequence
&diff{ arrive(T,V) - arrive(T,V') } <= -N :-
                                   start(R,V), not task_sequence(_,T), task(T,V'),
                                   assignment(R,T), shortest_path(V,V',N,_).

% Non-first paths
&diff{ arrive(P',V) - arrive(P',V') } <= -N :-
                                    path_sequence(P,P'), path(P,V), path(P',V'),
                                    shortest_path(V,V',N,_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
