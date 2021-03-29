% ------------------------------------------------------------------------------
% A fast path DL encoding that only tracks the arrival time at a vertex and not
% the departure time.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Robot task sequence assignment: Definition 4(i) + Definition 5
% ------------------------------------------------------------------------------

#include "task_sequencing.lp".

% ------------------------------------------------------------------------------
% Partial merging of Definition 4(ii) + Definition 6 (except 6(iii)) +
% Definitions 8 and 9.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% A walk consists of a sequence of paths for a robot; one for each task as well
% as a return home for each robot.
% ------------------------------------------------------------------------------

path(T,V) :- task(T,V).
path(R,V) :- home(R,V), not start(R,V).
path(R,V) :- assignment(R,_), home(R,V).

% ------------------------------------------------------------------------------

% Establish a set of path destinations; one for each task and one to get each
% robot home. Note, if a robot is already home and has no tasks it will have no
% homing path. Then generate an acyclic path for each path destination that ends
% at the path destination's vertex. Then match the first and last vertex visits
% to task sequences, robot start positions, and return home positions.
%
% Note: this encoding doesn't need a separate projection set because we track
% acyclic paths so know exactly when the path ends.
%
% ------------------------------------------------------------------------------

0 { move(T,V,V') : edge(V,V',_) } 1 :- path(T,_), edge(V,_,_).
0 { move(T,V,V') : edge(V,V',_) } 1 :- path(T,_), edge(V',_,_).

first_visit(T,V) :- move(T,V,_), not move(T,_,V).
last_visit(T,V) :-  move(T,_,V), not move(T,V,_).

:- #count{ V : first_visit(T,V) } > 1, path(T,_).
:- #count{ V : last_visit(T,V) } > 1, path(T,_).
:- last_visit(T,V), not path(T,V).
:- path(T,V), not last_visit(T,V).

visit(T,V)   :- first_visit(T,V).
visit(T,V')  :- visit(T,V), move(T,V,V').

% Special case if no moves is required to get to the path destination
last_visit(P,V) :- path(P,V), not move(P,_,V).
first_visit(P,V) :- path(P,V), not move(P,_,V).

% For a robot with no paths - no other robot can access that vertex
:- start(R,V), not path(R,_), visit(_,V).

% ------------------------------------------------------------------------------
% Match the start and end of paths connected to the same robot
% ------------------------------------------------------------------------------

% Paths that are connected to tasks
:- task_sequence(T,_), not task_sequence(_,T),
   assignment(R,T), start(R,V), not first_visit(T,V).
:- task_sequence(T,T'), task(T,V), not first_visit(T',V).

% Homing path has two cases depending on whether robot has assigned tasks.
:- path(R,_), not assignment(R,_), start(R,V), not first_visit(R,V).
:- task_sequence(_,T), not task_sequence(T,_), task(T,V),
   assignment(R,T), not first_visit(R,V).

% ------------------------------------------------------------------------------
% Travel times must satisfy edge weights. Also create an epsilon time transition
% between the end of one task and the start of the next task in a task sequence.
% ------------------------------------------------------------------------------

#const epsilon=10.

&diff{ arrive(T,V) - arrive(T,V') } <= -W       :- move(T,V,V'), edge(V,V',W).
&diff{ arrive(T,V) - arrive(T',V) } <= -epsilon :- task(T,V), task_sequence(T,T').
&diff{ arrive(T,V) - arrive(R,V) } <= -epsilon  :- task(T,V), not task_sequence(T,_),
                                                   assignment(R,T).

% ------------------------------------------------------------------------------
% Definition 7
%
% Deal with conflicts but only for the paths that are part of the walk of
% distinct robots.
% ------------------------------------------------------------------------------

same_walk(T,T')               :- same_robot(T,T').
same_walk(R,T)                :- assignment(R,T).

{ before(v,(P,V),(P',V')) }    :- visit(P,V), visit(P',V'),
                                  conflict(v,V,V'), P < P',
                                  not same_walk(P,P'),
                                  not same_walk(P',P).
before(v,(P',V'),(P,V))        :- visit(P,V), visit(P',V'),
                                  conflict(v,V,V'), P < P',
                                  not same_walk(P,P'),
                                  not same_walk(P',P),
                                  not before(v,(P,V),(P',V')).

{ before(e,(P1,(V1,V1')),(P2,(V2,V2'))) } :- move(P1,V1,V1'), move(P2,V2,V2'),
                                  conflict(e,(V1,V1'),(V2,V2')), P1 < P2,
                                  not same_walk(P1,P2),
                                  not same_walk(P2,P1).
before(e,(P2,(V2,V2')),(P1,(V1,V1')))     :- move(P1,V1,V1'), move(P2,V2,V2'),
                                  conflict(e,(V1,V1'),(V2,V2')), P1 < P2,
                                  not same_walk(P1,P2),
                                  not same_walk(P2,P1),
                                  not before(e,(P1,(V1,V1')),(P2,(V2,V2'))).

:- before(e,(P1,(V1,V1')),(P2,(V2,V2'))), not before(v,(P1,V1),(P2,V2)).
:- before(e,(P1,(V1,V1')),(P2,(V2,V2'))), not before(v,(P1,V1'),(P2,V2')).


% Start of walk must arrive first and end of walk must arrive last
:- path(P,V), not task(P,_), before(v,(P,V),(_,_)).
:- path(R,_), not task(R,_), not assignment(R,_),
   start(R,V), before(v,(_,_),(R,V)).
:- task_sequence(T,_), not task_sequence(_,T), assignment(R,T),
   start(R,V), before(v,(_,_),(R,V)).

% Ensure that connected paths maintain the same ordering. Note: this is ugly
% because must account for transition from task path to task path and task path
% to home path. Maybe define a path_sequence/2 predicate?
:- task(T,V), task_sequence(T,T'), visit(P,V'), conflict(v,V,V'),
   before(v,(T,V),(P,V')), not before(v,(T',V),(P,V')).
:- task(T,V), task_sequence(T,T'), visit(P,V'), conflict(v,V,V'),
   before(v,(P,V'),(T,V)), not before(v,(P,V'),(T',V)).

:- task(T,V), task_sequence(_,T), assignment(R,T), not task_sequence(T,_),
   visit(P,V'), conflict(v,V,V'),
   before(v,(T,V),(P,V')), not before(v,(R,V),(P,V')).
:- task(T,V), task_sequence(_,T), assignment(R,T), not task_sequence(T,_),
   visit(P,V'), conflict(v,V,V'),
   before(v,(P,V'),(T,V)), not before(v,(P,V'),(R,V)).


&diff{ arrive(P,V) - arrive(P',V') } <= 0  :- before(v,(P,V),(P',V')).

% ------------------------------------------------------------------------------
% Partial Definitions 9.
%
% Assignment dependency checking. - Only required for wait dependency because
% deliver dependency is for a single robot and handled by task sequencing.
% ------------------------------------------------------------------------------

&diff{ arrive(T,V) - arrive(T',V')} <= 0  :- depends(_,T,T'),
                                             task(T,V), task(T',V').

% ------------------------------------------------------------------------------
% Show for post-processing
% ------------------------------------------------------------------------------


#show task/2.
#show path/2.
#show assignment/2.
#show task_sequence/2.
#show visit/2.
#show move/3.

#show before/3.

#show same_walk/2.
