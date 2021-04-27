% ------------------------------------------------------------------------------
% A path DL encoding that tracks the arrival at a vertex but also the exit time
% from that vertex.
% ------------------------------------------------------------------------------

encoding(path).

% ------------------------------------------------------------------------------
% A walk consists of a sequence of paths for a robot; there must be a path for
% each task as well as a return home path for each robot that is not already
% home or has assignments.
% ------------------------------------------------------------------------------

path(T,V)           :- task(T,V).
path(R,V)           :- assignment(R,_), home(R,V).
path(R,V)           :- home(R,V), not start(R,V).

path_sequence(T,T') :- task_sequence(T,T').
path_sequence(T,R)  :- task_sequence(_,T), not task_sequence(T,_), assignment(R,T).

path_assignment(R,T)  :- assignment(R,T).
path_assignment(R,R)  :- assignment(R,_).
path_assignment(R,R)  :- home(R,V), not start(R,V).

% ------------------------------------------------------------------------------
% Generate a set of moves for each path. The path is acyclic and the start and
% end must match the expected start and end positions to satisfy the task.
% ------------------------------------------------------------------------------

0 { move(T,V,V') : edge(V,V',_) } 1 :- task(T,_), edge(V,_,_).
0 { move(T,V,V') : edge(V,V',_) } 1 :- task(T,_), edge(V',_,_).

0 { move(R,V,V') : edge(V,V',_) } 1 :- robot(R), edge(V,_,_).
0 { move(R,V,V') : edge(V,V',_) } 1 :- robot(R), edge(V',_,_).
:- robot(R), not path(R,_), move(R,_,_).

%%% PROGRAM IS TIGHT BUT IS THIS ALWAYS A GOOD THING?

visit(P,V) :- move(P,V,_).
visit(P,V) :- move(P,_,V).
first_visit(P,V) :- move(P,V,_), not move(P,_,V).
last_visit(P,V) :-  move(P,_,V), not move(P,V,_).

% Special case if no move is required to get to the path destination
last_visit(P,V) :- path(P,V), not move(P,_,_).
first_visit(P,V) :- path(P,V), not move(P,_,_).
visit(P,V) :- path(P,V), not move(P,_,_).

:- #count{ V : last_visit(P,V) } > 1, path(P,_).

:- path(P,V), not last_visit(P,V).
:- path(P,_), not first_visit(P,_).

% For a robot with no paths (so starts at its home vertex and has no
% assignments) - there should be no visits to its home vertex.
:- start(R,V), not path(R,_), visit(_,V).

% ------------------------------------------------------------------------------
% Match the start and end of paths that are part of a sequence.
% ------------------------------------------------------------------------------

% First visit for the first path - two cases if robot has assigments or not.
:- start(R,V), path_assignment(R,P),
   path_sequence(P,_), not path_sequence(_,P), not first_visit(P,V).
:- start(R,V), path(R,_), not assignment(R,_), not first_visit(R,V).

% Path sequences
:- path_sequence(P,P'), path(P,V), not first_visit(P',V).

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
% Definition 7
%
% Deal with conflicts but only for the paths that are part of the walk of
% distinct robots.
% ------------------------------------------------------------------------------

same_walk(T,T')                :- same_robot(T,T').
same_walk(R,T)                 :- assignment(R,T).
same_walk(Y,X)                 :- same_walk(X,Y).

% P must exit V before P' can arrive at V'
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
