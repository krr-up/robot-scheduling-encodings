%------------------------------------------------------------------------------
% The static data encodes a graph and timing for actions. The warehouse layout
% data is encoded as a set of edge/3 facts and the task and robot data is
% encoded with task/2 and home/2 facts. We can derive the vertices and shortest
% paths from the edge/3 data, as well as the endpoints of interested from the
% task/2 and and home/2 facts. Note: these are all domain predicates so can be
% fully grounded out before solving.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Make sure edges and conflicts are symmetric
% ------------------------------------------------------------------------------
edge(B,A,D)                   :- edge(A,B,D).
conflict(C2,C1)               :- conflict(C1,C2).
% ------------------------------------------------------------------------------
% Get the vertices and endpoints
% ------------------------------------------------------------------------------

vertex(V)   :- edge(V,_,_).
vertex(V)   :- edge(_,V,_).

endpoint(V) :- task(_,V).
endpoint(V) :- home(_,V).

% ------------------------------------------------------------------------------
% Every vertex has a nearest neighbour
% ------------------------------------------------------------------------------

nearest(V,V',D)       :- edge(V,V',D), #false : edge(V,_,D'), D' < D.

% ------------------------------------------------------------------------------
% Properties related to endpoints.
%
% 1) Every endpoint has an "entrypoint". This is a vertex that is the sole
% access point to the endpoint. This entrypoint could be endpoint node itself.
% entrypoint(V,V',D) encodes that V is an entrypoint to endpoint V' and the
% distance from V to V' is D.
%
% 2) Encode when a vertex is on a deadend path to some endpoint. on_deadend(V,V')
% encodes that V is on a deadend path to endpoint V'. Note: an endpoint is on a
% deadend to itself (provided that it isn't also the entrypoint)
%
% 3) deadend paths and the entry point together block access to an
% endpoint. endpoint_access(N,N') encodes that node N blocks access to endpoint
% N'.
% ------------------------------------------------------------------------------

maxdist(MD) :- MD = #sum { D,V,V' : edge(V,V',D) }.

_vertex(oneedge,V)      :- vertex(V), 1 { edge(V,_,_) } 1.
_vertex(twoedge,V)      :- vertex(V), 2 { edge(V,_,_) } 2.
_ep_to_next(V,V',D)     :- endpoint(V), _vertex(oneedge,V),
                           edge(V,V',D), not endpoint(V').

_ep_to_next(V,V'',D+D') :- _ep_to_next(V,V',D), edge(V',V'',D'),
                           V' != V'', V != V'', V != V',
                           maxdist(MD), D < MD,
                           _vertex(twoedge,V''), not endpoint(V'') .

entrypoint(V,V,0)       :- endpoint(V), _vertex(oneedge,V),
                           edge(V,V',_), endpoint(V').
entrypoint(V,V,0)       :- endpoint(V), not _vertex(oneedge,V).
entrypoint(V',V,D)      :- _ep_to_next(V,V',D),
                           #false : _ep_to_next(V,_,D'), D' < D.

on_deadend(V,V)         :- endpoint(V), _vertex(oneedge,V).
on_deadend(V,V')        :- _vertex(twoedge,V), edge(V,V'',_), on_deadend(V'',V').

endpoint_access(V,V')   :- on_deadend(V,V').
endpoint_access(V,V')   :- entrypoint(V,V',_).

% ------------------------------------------------------------------------------
% For calculating the shortest path from every node to the endpoints
% ------------------------------------------------------------------------------
%#program min_path.

edge_gathered        :- edge(V1,V2,D), @gather_edge(V1,V2,D) == 1.
endpoint_gathered    :- endpoint(V), @gather_endpoint(V) == 1.

% Shortest path from vertex V to end EP is distance D and via vertex V'

all_shortest_path(V,EP,D,V') :- (V,EP,D,V') = @shortest_paths(),
                                not edge_gathered, not endpoint_gathered.

% ------------------------------------------------------------------------------
% Calculate the shortest path between endpoints
% ------------------------------------------------------------------------------

startpoint(V)                   :- start(_,V).
startpoint(V)                   :- task(_,V).

rel_shortest_path(SP,EP,D,V)    :- startpoint(SP), endpoint(EP),
                                   all_shortest_path(SP,EP,D,V).
rel_shortest_path(V',EP,D',V'') :- rel_shortest_path(V,EP,D,V'),
                                   all_shortest_path(V',EP,D',V'').

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------


#show.
#show edge/3.
#show robot/1.
#show home/2.
#show start/2.
#show conflict/2.
#show task/2.
#show depends/3.

#show endpoint/1.
#show nearest/3.
#show entrypoint/3.
#show on_deadend/2.
#show endpoint_access/2.

#show all_shortest_path/4.

#show shortest_path(V,V',V'',D) : rel_shortest_path(V,V',V'',D).
%#show shortest_path(V,V',V'',D) : all_shortest_path(V,V',V'',D).

%%#show entrypoint/3.
%#show _vertex/2.
%#show _ep_to_next/3.
%%
