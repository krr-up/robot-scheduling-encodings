% ------------------------------------------------------------------------------
% If we have the shortest path information then we can calculate the mimimum
% distance between the destinations of some domain predicate
% path_sequences. Note: path_sequences that derive from depends(deliver,T,T')
% are domain predicates so their minimum distance will also be a domain
% predicate.
%
% Input facts: shortest_path(Src,Dest,N,Next), path(T,V), task(T,V).
%              depends(deliver,T,T'), path_sequence(P,P').
%
% Output: path_sequence(P,P',N).
%
% ------------------------------------------------------------------------------


&diff{ exit(T,V) - arrive(T',V') } <= -N :-
                                    depends(deliver,T,T'), task(T,V), task(T',V'),
                                    shortest_path(V,V',N,_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
