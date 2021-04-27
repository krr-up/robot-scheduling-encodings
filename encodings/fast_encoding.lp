% ------------------------------------------------------------------------------
% A fast path DL encoding that only tracks the arrival time at a vertex and not
% the departure time.
% ------------------------------------------------------------------------------

encoding(fast).

% ------------------------------------------------------------------------------
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
% Match the start and end of paths associated with the same robot
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

&diff{ arrive(P,V) - arrive(P,V') } <= -W       :- move(P,V,V'), edge(V,V',W).

% The transition from one task to the next must be at least epsilon time.
&diff{ arrive(P,V) - arrive(P',V) } <= -epsilon :- path(P,V), path_sequence(P,P').

% Make sure initial times are greater than zero. This is needed if we want to
% minimize the bound - otherwise it generates negative arrival times.

% Each robot must "arrive" at its starting location at exactly time 0. Note:
% must be exact to avoid boundary case where a robot "appears" only after time 0
% (see fast_unsat2.lp).
&diff{ 0 - arrive(P,V) } <= 0    :- path(P,_), not path_sequence(_,P),
                                    path_assignment(R,P), start(R,V).
&diff{ arrive(P,V) - 0 } <= 0    :- path(P,_), not path_sequence(_,P),
                                    path_assignment(R,P), start(R,V).

% All robots must return home before the upper bound.
&diff{ arrive(R,V) - bound } <= 0      :- home(R,V).

% ------------------------------------------------------------------------------
% Definition 7
%
% Deal with conflicts but only for the paths that are part of the walk of
% distinct robots.
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
% Arrival at a node based on the before(v,(P,V),(P',V')) relation. Because we
% don't track the exit times we ensure that P arrives at the vertex after V
% before P' arrives at V'.
% ------------------------------------------------------------------------------

&diff{ arrive(P,V'') - arrive(P',V') } <= 0  :-
                                       before(v,(P,V),(P',V')), move(P,V,V'').

% ------------------------------------------------------------------------------
% Two cases for edge conflicts that are not subsumed by the vertex conflicts.
% ------------------------------------------------------------------------------

&diff{ arrive(P,V2) - arrive(P',V1') } <= 0  :-
                                       before(v,(P,V2),(P',V2')),
                                       move(P,V1,V2), move(P',V1',V2'),
                                       conflict(e,(V1,V2),(V1',V2')).

&diff{ arrive(P,V2) - arrive(P',V1') } <= 0  :-
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

&diff{ arrive(T,V) - arrive(T',V')} <= -1  :- depends(wait,T,T'),
                                              task(T,V), task(T',V').

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

