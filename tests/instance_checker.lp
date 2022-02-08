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

% Vertices conflict with themselves
err(missing_self_conflict(V))    :- vertex(V), not conflict(V,V).

% Conflicts are symmetric
err(missing_conflict(V,V'))      :- conflict(V,V'), not conflict(V',V).

% Edges are assumed to be straight lines between two vertices so no edge
% from a vertex to itself.
err(symmetric_edge(V))           :- edge(V,V,_).

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
%
% ------------------------------------------------------------------------------

noerrors :- not err(_).


% ------------------------------------------------------------------------------
% Output
% ------------------------------------------------------------------------------


#show.
#show err/1.
#show noerrors.
