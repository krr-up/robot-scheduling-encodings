% ------------------------------------------------------------------------------
% A fast path DL encoding that only tracks the arrival time at a vertex and not
% the departure time.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% A walk consists of a sequence of paths for a robot; one for each task as well
% as a return home for each robot.
% ------------------------------------------------------------------------------

path(T,V)           :- task(T,V).
path(R,V)           :- home(R,V), not start(R,V).
path(R,V)           :- assignment(R,_), home(R,V).

path_sequence(T,T') :- task_sequence(T,T').
path_sequence(T,R)  :- task_sequence(_,T), not task_sequence(T,_), assignment(R,T).

passign(R,T)        :- assignment(R,T).
passign(R,R)        :- assignment(R,_).

path_seqnum(R,0)    :- passign(R,R), not assignment(R,_).
path_seqnum(P,0)    :- path_sequence(P,_), not path_sequence(_,P).
path_seqnum(P',N+1) :- path_seqnum(P,N), path_sequence(P,P'),
                       #count{ 1 : task(_,_) } = TN, N <= TN.

% ------------------------------------------------------------------------------
% Establish a set of path destinations; one for each task and one to get each
% robot home. Note, if a robot is already home and has no tasks it will have no
% homing path. Then generate an acyclic path for each path destination that ends
% at the path destination's vertex. Then match the first and last vertex visits
% to task sequences, robot start positions, and return home positions.
%
% Note: this encoding doesn't need a separate projection set because we track
% acyclic paths so know exactly when the path ends.
% ------------------------------------------------------------------------------

0 { move(P,V,V') : edge(V,V',_) } 1 :- path(P,_), edge(V,_,_).
0 { move(P,V,V') : edge(V,V',_) } 1 :- path(P,_), edge(V',_,_).

first_visit(P,V) :- move(P,V,_), not move(P,_,V).
last_visit(P,V) :-  move(P,_,V), not move(P,V,_).

:- #count{ V : first_visit(P,V) } > 1, path(P,_).
:- #count{ V : last_visit(P,V) } > 1, path(P,_).
:- last_visit(P,V), not path(P,V).
:- path(P,V), not last_visit(P,V).

visit(P,V)   :- first_visit(P,V).
visit(P,V')  :- visit(P,V), move(P,V,V').

% Special case if no moves is required to get to the path destination
last_visit(P,V) :- path(P,V), not move(P,_,_).
first_visit(P,V) :- path(P,V), not move(P,_,_).
visit(P,V) :- path(P,V), not move(P,_,_).

% For a robot with no paths (so starts at its home vertex and has no
% assignments) - there should be no visits to this home vertex.
:- start(R,V), not path(R,_), visit(_,V).

% ------------------------------------------------------------------------------
% Match the start and end of paths connected to the same robot
% ------------------------------------------------------------------------------

% First visit for the first path - two cases if robot has assigments or not.
:- start(R,V), passign(R,P),
   path_sequence(P,_), not path_sequence(_,P), not first_visit(P,V).
:- start(R,V), path(R,_), not assignment(R,_), not first_visit(R,V).

% Path sequences
:- path_sequence(P,P'), path(P,V), not first_visit(P',V).

% ------------------------------------------------------------------------------
% Travel times must satisfy edge weights. Also create an (exactly) epsilon time
% transition between the end of one task and the start of the next task in a
% task sequence.
% ------------------------------------------------------------------------------

#const epsilon=10.

&diff{ arrive(P,V) - arrive(P,V') } <= -W       :- move(P,V,V'), edge(V,V',W).

&diff{ arrive(P,V) - arrive(P',V) } <= -epsilon :- path(P,V), path_sequence(P,P').
&diff{ arrive(P',V) - arrive(P,V) } <= epsilon  :- path(P,V), path_sequence(P,P').

% This is needed if we want to minimize the bound - otherwise it generates
% negative arrival times.
&diff{ 0 - arrive(P,V) } <= 0          :- visit(P,V).

% Returning home before some bound.
&diff{ arrive(R,V) - bound } <= 0      :- robot(R), path(R,V).

% ------------------------------------------------------------------------------
% Definition 7
%
% Deal with conflicts but only for the paths that are part of the walk of
% distinct robots.
% ------------------------------------------------------------------------------

same_walk(T,T')                :- same_robot(T,T').
same_walk(R,T)                 :- assignment(R,T).
same_walk(Y,X)                 :- same_walk(X,Y).

{ before(v,(P,V),(P',V')) }    :- visit(P,V), visit(P',V'),
                                  conflict(v,V,V'), P < P',
                                  not same_walk(P,P').
before(v,(P',V'),(P,V))        :- visit(P,V), visit(P',V'),
                                  conflict(v,V,V'), P < P',
                                  not same_walk(P,P'),
                                  not before(v,(P,V),(P',V')).

before(e,(P1,V1'),(P2,V2))     :-  move(P1,V1,V1'), move(P2,V2,V2'),
                                   conflict(e,(V1,V1'),(V2,V2')),
                                   before(v,(P1,V1'),(P2,V2')).

% The start of a robot's walk must be first at the starting vertex (there are
% two cases: robot with/without an assignment)
:- start(R,V), path(R,_), not assignment(R,_), before(v,(_,_),(R,V)).
:- start(R,V), passign(R,P),
   path_sequence(P,_), not path_sequence(_,P), before(v,(_,_),(P,V)).

% The end of a robot's walk must arrive at its destination last
:- robot(R), path(R,V), before(e,(R,V),(_,_)).
:- robot(R), path(R,V), before(v,(R,V),(_,_)).

% Ensure the transition between two paths is reflected in the before/3 relation
:- path(P,V), before(v,(P,V), (P',V')), path_sequence(P,P''),
   not before(v,(P'',V),(P',V')).

% ------------------------------------------------------------------------------
% Arrival at a node based on the before/3 relation
% ------------------------------------------------------------------------------

&diff{ arrive(P,V) - arrive(P',V') } <= -1    :- before(v,(P,V),(P',V')).
&diff{ arrive(P,V) - arrive(P',V') } <= 0     :- before(e,(P,V),(P',V')).

% ------------------------------------------------------------------------------
% Track successive moves to make sure there are no swap or overtaking actions
% ------------------------------------------------------------------------------

next_move((P,V),(P,V'))  :- move(P,V,V').
next_move((P,V),(P',V')) :- path(P,V),  passign(R,P), path_seqnum(P,X),
                            passign(R,P'), path_seqnum(P',Z), move(P',V,V'), X < Z,
                            #false : passign(R,P''), path_seqnum(P'',Y),
                                     move(P'',_,_), X < Y, Y < Z.

% Prevent robots that are moving in the same direction from overtaking. If two
% robot move in the same directions over two nodes then one robot must complete
% both moves before the other.
:- next_move((P1,V1),(P2,V2)), next_move((P1',V1'),(P2',V2')),
   conflict(v,V1,V1'), conflict(v,V2,V2'), before(v,(P1,V1),(P1',V1')),
   not before(v,(P2,V2),(P2',V2')).

% Prevent robots that are moving in the opposite direction from swapping. If two
% robot move in opposite directions over two nodes then one robot must complete
% both moves before the other.
:- next_move((P1,V1),(P2,V2)), next_move((P1',V1'),(P2',V2')),
   conflict(v,V1,V2'), conflict(v,V2,V1'), before(v,(P1,V1),(P2',V2')),
   not before(v,(P2,V2),(P1',V1')).

% ------------------------------------------------------------------------------
% Ensure that connected paths maintain the same ordering.
% ------------------------------------------------------------------------------

:- before(v,(P,V),(P',V')), passign(R,P), path_seqnum(P,N),
   visit(P'',V), passign(R,P''), path_seqnum(P'',N''), N'' < N,
   not before(v,(P'',V),(P',V')).

% ------------------------------------------------------------------------------
% Partial Definitions 9.
%
% Assignment dependency checking. - Only required for wait dependency because
% deliver dependency is for a single robot and handled by task sequencing.
% ------------------------------------------------------------------------------

&diff{ arrive(T,V) - arrive(T',V')} <= 0  :- depends(_,T,T'),
                                             task(T,V), task(T',V').

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

