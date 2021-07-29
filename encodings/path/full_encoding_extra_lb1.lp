% ------------------------------------------------------------------------------
% If we have the shortest path information then we can calculate the mimimum
% distance between the destinations for delivery dependent tasks, that is the
% tasks depends(deliver,T,T'). These are domain predicates so their minimum
% distance will also be a domain predicate.
%
% NOTE: Don't use this. It is more limited than full_encoding_extra_lb2.lp and
% experimentally the non-domain information that lb2 improves things and doesn't
% have any down side.
%
% Input facts: shortest_path(Src,Dest,N,Next), path(T,V), task(T,V).
%              depends(deliver,T,T').
%
% Output: sets DL constraints
%
% ------------------------------------------------------------------------------


&diff{ exit(T,V) - arrive(T',V') } <= -N :-
                                    depends(deliver,T,T'), task(T,V), task(T',V'),
                                    shortest_path(V,V',N,_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
