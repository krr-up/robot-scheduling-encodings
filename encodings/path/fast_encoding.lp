% ------------------------------------------------------------------------------
% A "fast" path DL encoding that only tracks the arrival time at a vertex and not
% the departure time.
% ------------------------------------------------------------------------------

encoding(fast).

% ------------------------------------------------------------------------------
% Assign tasks to robots and generate a task sequence for each robot.
% ------------------------------------------------------------------------------

%#include "common/task_assignment.lp".
%#include "common/task_sequencing_direct.lp".

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

