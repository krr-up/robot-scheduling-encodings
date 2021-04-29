% ------------------------------------------------------------------------------
% A path DL encoding that tracks the arrival at a vertex but also the exit time
% from that vertex.
% ------------------------------------------------------------------------------

encoding(path).

% ------------------------------------------------------------------------------
% Assign tasks to robots and generate a task sequence for each robot.
% ------------------------------------------------------------------------------

%#include "common/task_sequencing.lp".
%#include "common/task_sequencing_heur.lp".

% ------------------------------------------------------------------------------
% Map each task, task assignment, and task sequence to paths.
% ------------------------------------------------------------------------------

%#include "path/task_to_path.lp".

% ------------------------------------------------------------------------------
% Import a move choice module and extra domain heuristics
% ------------------------------------------------------------------------------

%#include "path/move_choice_domain.lp".
%#include "path/move_choice_nondomain.lp".
%#include "path/move_choice_heur.lp".

% ------------------------------------------------------------------------------
% Ensure that the move choices for a path form a proper sequence and ensure that
% each path starts and ends and the appropriate vertices.
% ------------------------------------------------------------------------------

%#include "path/move_sequencing.lp".

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


% Import a visit tracker to work out all vertices that are visited by a path:
% visit_tracker_tight.lp or visit_tracker_nontight.lp.
% ------------------------------------------------------------------------------

%#include "path/visit_tracker_tight.lp".
%#include "path/visit_tracker_nontight.lp".

% ------------------------------------------------------------------------------
% Construct a set of vertex visit orderings that we can then test to determine a
% a conflict free assigment.
% ------------------------------------------------------------------------------

%#include "path/visit_ordering.lp".
%#include "path/visit_ordering_extra.lp".

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
