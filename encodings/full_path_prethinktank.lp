%!flags! --heuristic=Domain
%!desc! Encoding before August 2021 thinktank


% ------------------------------------------------------------------------------
% Assigning tasks to robots with some ordering
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% #include "task_assignment.lp".
%
% This version improves grounding - don't choose putdown task assignments since
% they are completely determined by the pickup assignments.
% ------------------------------------------------------------------------------

1 { assignment(R,T) : robot(R) } 1 :- task(T,_), not depends(deliver,_,T).
assignment(R,T')                   :- assignment(R,T), depends(deliver,T,T').

same_robot(T,T')  :- assignment(R,T), assignment(R,T'), T < T'.


% ------------------------------------------------------------------------------
% #include "task_sequencing_direct.lp".
%
% Don't choose pickup-putdown sequences since they are completely determined by
% the pickup.  Make sure each robot with assignments has a linear task sequences
% are linear (see note above that there could still be a secondary cyclic task
% sequence).
% ------------------------------------------------------------------------------

0 { task_sequence(T,T') : task(T',_), not depends(deliver,_,T'), T != T' } 1 :-
                          task(T,_), not depends(deliver,T,_).
task_sequence(T,T')     :- depends(deliver,T,T').

:- task_sequence(T,T'), not same_robot(T,T'), not same_robot(T',T).

:- task_sequence(T',T), task_sequence(T'',T), T' < T''.
:- task(T,_), not task_sequence(T,_), not task_sequence(_,T).

:- robot(R), #count{ T : assignment(R,T), not task_sequence(_,T) } > 1.

% I think this is redundant????
:- assignment(R,_),
   #false : assignment(R,T), task_sequence(T,_), not task_sequence(_,T).


% ------------------------------------------------------------------------------
% #include "task_sequencing_extra_edge.lp".
%
% Use clingo #edge for cycle detection. Ensures a proper task sequences that
% doesn't rely on the DL constraints. In particular: 1) a robot with an
% assignment can have only a single task sequence and it is guaranteed to be
% linear, 2) wait dependencies has satisfied (both within a single robot
% assignment and between robot assignments).
%
% Note: it is still possible for an set of task sequences to be unsatisfiable
% but (I think) this is only possible if the robots can block each other within
% the warehouse graph. And this can only be determine by the routing.
% ------------------------------------------------------------------------------

_tpo_seq(T,T') :- task_sequence(T,T').
_tpo_seq(T,T') :- depends(wait,T,T').

#edge (T,T') : _tpo_seq(T,T').

% ------------------------------------------------------------------------------
% #include "task_to_path.lp".
%
% A walk consists of a sequence of paths for a robot; there must be a path for
% each task as well as a return home path for each robot that is not already
% home or has assignments.
% ------------------------------------------------------------------------------

path(T,V)             :- task(T,V).
path(R,V)             :- assignment(R,_), home(R,V).
path(R,V)             :- home(R,V), not start(R,V).

path_sequence(T,T')   :- task_sequence(T,T').
path_sequence(T,R)    :- task_sequence(_,T), not task_sequence(T,_), assignment(R,T).

path_assignment(R,T)  :- assignment(R,T).
path_assignment(R,R)  :- assignment(R,_).
path_assignment(R,R)  :- home(R,V), not start(R,V).


% ------------------------------------------------------------------------------
% #include "move_choice_corr2.lp".
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Generate moves along a corridor separating the domain from non-domain
% predicates and define a domain grounding of possible corridors for the
% corridors that can't be determined at grounding.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% #include "minpath2.lp".
%
% Generate minimum paths; explicitly separating the minimum paths that for
% putdown tasks, which are dependant only on domain predicates, from the pickup
% and return home paths, which are dependent on choices. For these second
% minimum paths we define a 3-arity domain-predicate minpath by tracking the
% to-from paths.  From this 3-arity minpath we can then define a non-domain
% minpath.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% The domain predicate minimum paths can be defined for putdown tasks
% ------------------------------------------------------------------------------

path_minpath_d(T',V)    :- depends(deliver,T,T'), task(T,V).
path_minpath_d(T,V'')   :- path_minpath_d(T,V), task(T,V'),
                            shortest_path(V,V',_,V'').

% ------------------------------------------------------------------------------
% Domain predicate of possible minimum paths that tracks the to-from
% paths. Three cases: 1) a robot returning home, 2) a robot moving to the first
% assigned task, 3) a robot that's finished a putdown task and moving on to the
% next pickup task. For robots returning home there are two sub-cases: 1) they
% have no assignments, 2) they have finished their assigned tasks.
% ------------------------------------------------------------------------------

path_minpath(R,R,V)     :- start(R,V).

path_minpath(T,R,V)     :- robot(R), depends(deliver,_,T), task(T,V).
path_minpath(P,R,V'')   :- path_minpath(P,R,V), home(R,V'),
                            shortest_path(V,V',_,V'').
path_minpath(R,T,V)     :- start(R,V), depends(deliver,T,_).
path_minpath(T',T'',V') :- depends(deliver,T,T'), task(T',V'),
                            depends(deliver,T'',_), T != T''.
path_minpath(P,T,V'')   :- path_minpath(P,T,V), task(T,V'),
                            shortest_path(V,V',_,V'').


% ------------------------------------------------------------------------------
% From the (domain predicate) path_minpath/3 define a non-domain predicate
% path_minpath_nd/2. Four cases: 1) robot without assignments returning home, 2)
% robot with finished assignments returning home, 3) robot moving to first
% pickup task, 4) robot moving to subsequent pickup task.
% ------------------------------------------------------------------------------

path_minpath_nd(R,V)     :- path_minpath(R,R,V), not assignment(R,_), path(R,_).
path_minpath_nd(R,V)     :- path_minpath(T,R,V), path_sequence(T,R), not path_sequence(R,_).
path_minpath_nd(T,V)     :- path_minpath(R,T,V), assignment(R,T),
                             task_sequence(T,_), not task_sequence(_,T).
path_minpath_nd(T',V)    :- path_minpath(T,T',V), task_sequence(T,T'), task(T',_).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

%------------- OK TO HERE --------------------------------------




% ------------------------------------------------------------------------------
% Limit the move selection to a "corridor" around the shortest path. For putdown
% paths the corridor can be ground out. In such cases the corridor is defined
% as follows: 1) the minimum path from the source to destination is on the
% corridor, 2) every node directly connected to a node on the minimum path is
% also on the corridor provided that the distance to the destination from that
% connected node is not greater than the distance from the minimum path node.
% ------------------------------------------------------------------------------

path_corr_d(T,V)  :- task(T,V), depends(deliver,_,T).
path_corr_d(T,V)  :- path_minpath_d(T,V).
path_corr_d(T,V') :- path_minpath_d(T,V), edge(V,V',_), task(T,V''),
                     shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.

% ------------------------------------------------------------------------------
% Pick moves for paths that have domain predicate corridors
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_), path_corr_d(P,V') } 1 :-
                                                 path_corr_d(P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_corr_d(P,V) } 1 :-
                                                 path_corr_d(P,V'), edge(_,V',_).

% ------------------------------------------------------------------------------
% For pickup tasks the starting location can vary depending on the task
% sequence. So we can't define the corridor using only domain
% predicates. Instead define a non-domain path corridor and separately define a
% larger grounding that encompasses all possibilities. The move choice is then
% defined over the domain grounding and subsequently restricted to the
% non-domain corridor.
% ------------------------------------------------------------------------------

path_corr(P,P',V)  :- path_minpath(P,P',V).
path_corr(P,T,V') :- path_corr(P,T,V), edge(V,V',_), task(T,V''),
                       shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.
path_corr(P,R,V') :- path_corr(P,R,V), edge(V,V',_), home(R,V''),
                       shortest_path(V,V'',N,_), shortest_path(V',V'',N',_), N' <= N.

% ------------------------------------------------------------------------------
% Pick moves for paths that have from-to path corridors that are domain
% predicates and then restrict the moves to the non-domain path corridors.
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_), path_corr(_,P,V') } 1 :-
                                          path_corr(_,P,V), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_), path_corr(_,P,V) } 1 :-
                                          path_corr(_,P,V'), edge(_,V',_).
:- robot(R), not path(R,_), move(R,_,_).

:- move(P',V,V'), path_sequence(P,P'), path_corr(_,P',_),
   not path_corr(P,P',V), not path_corr(P,P',V').

:- move(R,V,V'), robot(R), not assignment(R,_),
   not path_corr(R,R,V), not path_corr(R,R,V').


% ------------------------------------------------------------------------------
% #include "move_sequencing.lp".
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Make sure the move sequence visits the required path vertices in the correct
% order; and if a robot is unassigned and has no paths then it doesn't move.
%
% Inputs: move/3, start/2, path/2, path_assignment/2, path_sequence/2.
% Outputs: first_visit/2. last_visit/2.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Define the first and last visit based on the moves
% ------------------------------------------------------------------------------

first_visit(P,V) :- move(P,V,_), not move(P,_,V).
last_visit(P,V) :-  move(P,_,V), not move(P,V,_).

% Special case if a robot is already at its path destination
last_visit(P,V) :- path(P,V), not move(P,_,_).
first_visit(P,V) :- path(P,V), not move(P,_,_).

% ------------------------------------------------------------------------------
% Because the move choices ensure that for any vertex connected to a path there
% can be at most one incoming edge and at most one outgoing edge, we therefore
% only need to look at the last vertex visited to ensure that a path is a single
% unbroken sequence that ends at the appropriate vertex.
% ------------------------------------------------------------------------------

:- #count{ V : last_visit(P,V) } > 1, path(P,_).
:- path(P,V), not last_visit(P,V).

% ------------------------------------------------------------------------------
% Match the start and end of paths associated with the same robot
% ------------------------------------------------------------------------------

% First visit for the first path - two cases if robot has assigments or not.
:- start(R,V), path_assignment(R,P),
   path_sequence(P,_), not path_sequence(_,P), not first_visit(P,V).
:- start(R,V), path(R,_), not assignment(R,_), not first_visit(R,V).

% Path sequences
:- path_sequence(P,P'), path(P,V), not first_visit(P',V).

% ------------------------------------------------------------------------------
% For a robot with nothing to do (so it starts at its home vertex and has no
% assignments) - there should be no moves to or from its home vertex.
% ------------------------------------------------------------------------------

%:- start(R,V), not path(R,_), visit(_,V).

:- start(R,V), not path(R,_), move(_,V,_).
:- start(R,V), not path(R,_), move(_,_,V).


% ------------------------------------------------------------------------------
% #include "visit_ordering.lp".
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Decide the order in which robots visit a vertex (as part of a given path) to
% ensure a conflict free ordering.
%
% Input: same_robot/2, assignment/2, path_assignment/2, visit/2, conflict/3,
%        start/2, path/2, move/3,
%
% Output: before/3, same_walk/2 (auxiliary).
%
% ------------------------------------------------------------------------------

same_walk(T,T')                :- same_robot(T,T').
same_walk(R,T)                 :- assignment(R,T).
same_walk(Y,X)                 :- same_walk(X,Y).

% P visits V before P' visit V'
{ before(v,(P,V),(P',V')) }    :- visit(P,V), visit(P',V'),
                                  conflict(v,V,V'), P < P',
                                  not same_walk(P,P').
before(v,(P',V'),(P,V))        :- visit(P,V), visit(P',V'),
                                  conflict(v,V,V'), P < P',
                                  not same_walk(P,P'),
                                  not before(v,(P,V),(P',V')).

% The start of a robot's walk must be first at the starting vertex (there are
% two cases: robot with/without an assignment)
:- start(R,V), path(R,_), not assignment(R,_), before(v,(_,_),(R,V)).
:- start(R,V), path_assignment(R,P),
   path_sequence(P,_), not path_sequence(_,P), before(v,(_,_),(P,V)).

% The end of a robot's walk must arrive at its destination last
:- robot(R), path(R,V), before(v,(R,V),(_,_)).

% Ensure the transition between two paths is reflected in the before/3 relation
:- before(v,(P,V),(P',V')), path(P,V), path_sequence(P,P''),
   not before(v,(P'',V),(P',V')).

% ------------------------------------------------------------------------------
% Track successive moves to make sure there are no swap or overtaking actions
% ------------------------------------------------------------------------------

% Prevent robots that are moving in the same direction from overtaking. If two
% robot move in the same directions over two nodes then one robot must complete
% both moves before the other.
:- move(P,V1,V2), move(P',V1',V2'),
   conflict(v,V1,V1'), conflict(v,V2,V2'), before(v,(P,V1),(P',V1')),
   not before(v,(P,V2),(P',V2')).


% Prevent robots that are moving in the opposite direction from swapping. If two
% robot move in opposite directions over two nodes then one robot must complete
% both moves before the other.
:- move(P,V1,V2), move(P',V1',V2'),
   conflict(v,V1,V2'), conflict(v,V2,V1'), before(v,(P,V1),(P',V2')),
   not before(v,(P,V2),(P',V1')).

% ------------------------------------------------------------------------------
% #include "visit_tracker_tight.lp".
% ------------------------------------------------------------------------------

visit(P,V) :- move(P,V,_).
visit(P,V) :- path(P,V).

% ------------------------------------------------------------------------------
% #include "full_encoding.lp".
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Travel times must satisfy edge weights. Transition between tasks must satisfy
% epsilon time delay.
% ------------------------------------------------------------------------------

#const epsilon=10.

% Travel times along a vertex and edge - note: a robot "exits" its final
% destination at the upper bound.

&diff{ arrive(P,V) - exit(P,V) } <= 0        :- visit(P,V).
&diff{ exit(P,V) - arrive(P,V') } <= -W      :- move(P,V,V'), edge(V,V',W).

% Action time
&diff{ arrive(T,V) - exit(T,V) } <= -epsilon :- visit(T,V), task(T,V).

% Match end of one task and start of next
&diff{ exit(P,V) - arrive(P',V) } <= 0       :- path_sequence(P,P'), path(P,V).


% Each robot must "arrive" at its starting location at exactly time 0. Note:
% must be exact to avoid boundary case where a robot "appears" only after time 0.
&diff{ 0 - arrive(P,V) } <= 0    :- path(P,_), not path_sequence(_,P),
                                    path_assignment(R,P), start(R,V).
&diff{ arrive(P,V) - 0 } <= 0    :- path(P,_), not path_sequence(_,P),
                                    path_assignment(R,P), start(R,V).

% Returning home before the upper bound.
&diff{ arrive(R,V) - bound } <= 0      :- home(R,V).
&diff{ exit(R,V) - bound } <= 0        :- home(R,V).
&diff{ bound - exit(R,V) } <= 0        :- home(R,V).


% ------------------------------------------------------------------------------
% Handle the before(v,(P,V),(P',V')) predicate.  NOTE: We are modelling a vertex
% as taking up space enough to contain a robot. Therefore we can have a robot
% exit a node at the same instance that another robot arrives at that node. But
% we are also allowing a robot to arrive and exit a node at the same
% instant. This creates a problem that before(v,(P,V),(P',V)) allows P and P' to
% both arrive and exit the node at the same instant without violating the
% constraint. We could add a delay between arriving and exiting, but instead
% make sure two robots cannot arrive at the same time.
% ------------------------------------------------------------------------------

&diff{ arrive(P,V) - arrive(P',V') } <= -1  :- before(v,(P,V),(P',V')).
&diff{ exit(P,V) - arrive(P',V') } <= 0     :- before(v,(P,V),(P',V')).

% ------------------------------------------------------------------------------
% Two cases for edge conflicts that are not subsumed by the vertex conflicts.
% ------------------------------------------------------------------------------

&diff{ arrive(P,V2) - exit(P',V1') } <= 0  :-
                                       before(v,(P,V2),(P',V2')),
                                       move(P,V1,V2), move(P',V1',V2'),
                                       conflict(e,(V1,V2),(V1',V2')).

&diff{ arrive(P,V2) - exit(P',V1') } <= 0  :-
                                       before(v,(P,V1),(P',V2')),
                                       move(P,V1,V2), move(P',V1',V2'),
                                       conflict(e,(V1,V2),(V1',V2')).

% ------------------------------------------------------------------------------
% Assignment dependency checking only required for wait dependency because
% deliver dependency is for a single robot and handled by task sequencing.
% Note: the following relies on replacement/wait dependency being at the same
% vertex so the before/3 constraints will ensure that the two robots cannot be
% on the vertex at the same time.
% ------------------------------------------------------------------------------

&diff{ exit(T,V) - arrive(T',V')} <= 0  :- depends(wait,T,T'),
                                           task(T,V), task(T',V').

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% #include "full_encoding_extra_lb2.lp".
%
% If we have the shortest path information then we can calculate the mimimum
% distance between the destinations for path_sequences.
% Note: path_sequences that derive from depends(deliver,T,T')
% are domain predicates so their minimum distance will also be a domain
% predicate.
% ------------------------------------------------------------------------------


% Robot with no assignments returning home
&diff{ exit(R,V) - arrive(R,V') } <= -N :-
                                   start(R,V), home(R,V'), V != V',
                                   not assignment(R,_), shortest_path(V,V',N,_).

% First in the task sequence
&diff{ exit(T,V) - arrive(T,V') } <= -N :-
                                   start(R,V), not task_sequence(_,T), task(T,V'),
                                   assignment(R,T), shortest_path(V,V',N,_).

% Non-first paths
&diff{ exit(P',V) - arrive(P',V') } <= -N :-
                                    path_sequence(P,P'), path(P,V), path(P',V'),
                                    shortest_path(V,V',N,_).

% ------------------------------------------------------------------------------
% #include "replacement_time_bound.lp".
%
% Fix a time bound for the time between a delivery pickup and replacement
% putdown item. This establishes a quality requirement on the solution.
%
% Input: depends(wait,T,T'), task(T,V).
%
% Output: sets DL constraints
% ------------------------------------------------------------------------------

% Note: we don't have a precise notion of time. But treating 10 time points as 1
% second. So 2 minutes is:
%#const repl_time=2*600.

% NOTE: strictly speaking I'm not sure this captures the semantics of what is
% meant by the replacement time. The start time should be the earliest time that
% a robot has picked up the item, and the end time should be the time that a
% robot has putdown the item. The end time could also more correctly be the time
% that the robot that has putdown the item has had enough time to move to the
% next vertex (because only then can some arm robot putdown a new item for
% delivery). However, at least for the moment, only looking at the arrival times
% seems like a good enough simplification. It works for both the full and fast
% encodings and is fully grounded.

%%&diff{ arrive(T',V') - arrive(T,V) } <= repl_time :-
%%                                    depends(wait,T,T'), task(T,V), task(T',V').


% ------------------------------------------------------------------------------
%
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% #include "move_corr2_heur1.lp".
%
% Domain heuristics for improving move selection based on precomputed shortest
% path relations. Handle both domain and non-domain predicate based moves.
% ------------------------------------------------------------------------------

#heuristic move(P,V,V')  : path_minpath_d(P,V), path(P,V''),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : path_corr_d(P,V), edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]


#heuristic move(P,V,V')  : path_minpath_nd(P,V), path(P,V''),
                           shortest_path(V,V'',_,V'), V != V'.      [1,sign]

#heuristic move(P,V,V')  : path_corr(_,P,V), edge(V,V',_), path(P,V''),
                           not shortest_path(V,V'',_,V').           [1,false]


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------


#show.

#show assignment/2.
#show task_sequence/2.
#show move/3.
#show task/2.
#show depends/3.
#show start/2.
#show robot/1.
