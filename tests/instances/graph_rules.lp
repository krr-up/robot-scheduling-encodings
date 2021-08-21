% ------------------------------------------------------------------------------
% Standard rules for the graphs
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Undirected edges
% ------------------------------------------------------------------------------

edge(V',V,W) :- edge(V,V',W).

% ------------------------------------------------------------------------------
% Rules for conflicts: 1) each vertex conflicts with itself, 2) each edge
% conflicts with itself, 3) conflicts are symmetric, 4) if two sets of adjacent
% vertices conflict then their edges conflict.
% ------------------------------------------------------------------------------

conflict(v,V,V;v,V',V')       :- edge(V,V',_).
conflict(e,(V,V'),(V,V'))     :- edge(V,V',_).
conflict(e,(V,V'),(V',V))     :- edge(V,V',_).

% symmetry
conflict(T,Y,X)              :- conflict(T,X,Y).

conflict(e,(V2,V1),(V3,V4))   :- conflict(e,(V1,V2),(V3,V4)).
conflict(e,(V1,V2),(V4,V3))   :- conflict(e,(V1,V2),(V3,V4)).

% adjacent sets of vectices conflict then the edges must conflict
conflict(e,(V1,V3),(V2,V4))   :- conflict(v,V1,V2), conflict(v,V3,V4),
                                 edge(V1,V3,_), edge(V2,V4,_).


% ------------------------------------------------------------------------------
% show
% ------------------------------------------------------------------------------

%#show conflict/3.
