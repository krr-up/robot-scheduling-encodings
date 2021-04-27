% ------------------------------------------------------------------------------
% Instance checker makes sure that the input (the warehouse graph as well as the
% task graph) satisfies our assumptions. This is also a good place to document
% the assumptions.
%
% Produces: err/1.
% ------------------------------------------------------------------------------


% ------------------------------------------------------------------------------
% Every robot has a start and home position
% ------------------------------------------------------------------------------

err(missing_robot_start(R))      :- robot(R), not start(R,_).
err(missing_robot_home(R))       :- robot(R), not home(R,_).
err(missing_home_robot(R))       :- home(R,_), not robot(R).
err(missing_start_robot(R))      :- start(R,_), not robot(R).

% ------------------------------------------------------------------------------
% Warehouse graph
% ------------------------------------------------------------------------------
vertex(V) :- edge(V,_,_).
vertex(V) :- edge(_,V,_).

% Only positive weights
err(invalid_edge_weight(V,V',W)) :- edge(V,V',W), W <= 0.

% A bidirectional graph
err(missing_edge(V,V))           :- edge(V,V',W), not edge(V',V,W).

% Vertices and edges conflict with themselves
err(missing_self_conflict(V))    :- vertex(V), not conflict(v,V,V).
err(missing_self_conflict(V,V')) :- edge(V,V',_), not conflict(e,(V,V'),(V,V')).

% Conflicts are symmetric
err(missing_v_conflict(V,V'))    :- conflict(v,V,V'), not conflict(v,V',V).
err(missing_e_conflict((V1',V2'),(V1,V2)))
                                 :- conflict(e,(V1,V2),(V1',V2')),
                                    not conflict(e,(V1',V2'),(V1,V2)).
err(missing_e_conflict((V2,V1),(V1',V2')))
                                 :- conflict(e,(V1,V2),(V1',V2')),
                                    not conflict(e,(V2,V1),(V1',V2')).

% Edges are assumed to be straight lines between two vertices. So: 1) no edge
% from a vertex to itself, 2) if two pairs of connected vertices conflict then
% the corresponding edges must conflict, 2) if two edges conflict then at least
% one pair of the vertices must conflict.
err(symmetric_edge(V))           :- edge(V,V,_).
err(missing_edge_conflict((V1,V2),(V1',V2')))
                                 :- conflict(v,V1,V1'), conflict(v,V2,V2'),
                                    edge(V1,V2,_), edge(V1',V2',_),
                                    not conflict(e,(V1,V2),(V1',V2')).

err(missing_edge_matching_vertex_conflict((V1,V2),(V1',V2')))
                                 :- conflict(e,(V1,V2),(V1',V2')),
                                    not conflict(v,V1,V1'),
                                    not conflict(v,V2,V2'),
                                    not conflict(v,V1,V2'),
                                    not conflict(v,V2,V1').

% ------------------------------------------------------------------------------
% Task graph We are modelling delivering a full pallet from A to B and having a
% replacement pallet put down at A. So:
% 1) each task is either a pickup or putdown for a deliver dependency.
% 2) the pickup and putdown locations must be different.
% 3) the replacement/wait dependency must be at the same vertex
% ------------------------------------------------------------------------------

err(non_deliver_task(T))         :- task(T,_), not depends(deliver,T,_),
                                    not depends(deliver,_,T).
err(mismatched_replacement_task(T,T'))
                                 :- task(T,V), task(T',V'), depends(wait,T,T'),
                                    V != V'.

% ------------------------------------------------------------------------------
% Output
% ------------------------------------------------------------------------------


#show.
#show err/1.
