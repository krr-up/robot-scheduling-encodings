% ------------------------------------------------------------------------------
% A path DL encoding that tracks the arrival at a vertex but also the exit time
% from that vertex.
% ------------------------------------------------------------------------------

encoding(full).
encoding(path).

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

%#include "path/move_choice_open.lp".
%#include "path/move_choice_heur_sf.lp".

% ------------------------------------------------------------------------------
% Ensure that the move choices for a path form a proper sequence and ensure that
% each path starts and ends and the appropriate vertices.
% ------------------------------------------------------------------------------

%#include "path/move_sequencing.lp".

% ------------------------------------------------------------------------------
% Travel times must satisfy edge weights. Transition between tasks must satisfy
% kappa time delay.
% ------------------------------------------------------------------------------

#const kappa=10.

% Travel times along a vertex and edge - note: a robot "exits" its final
% destination at the upper bound.

&diff{ arrive(P,V) - exit(P,V) } <= 0        :- visit(P,V).
&diff{ exit(P,V) - arrive(P,V') } <= -W      :- move(P,V,V'), edge(V,V',W).

% Action time
&diff{ arrive(T,V) - exit(T,V) } <= -kappa :- visit(T,V), task(T,V).

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
% Map the before((P,V),(P',V')) predicates into appropriate timing
% constraints. The before predicates are only created for two paths where the
% two paths are assigned to distinct robots. So if a robot R arrives at vertex
% V (as part of path P) before a robot R' arrives at vertex V' (as part of path
% P') then R must arrive at the subsequent vertex V'' on path P no later than
% R' arrives at V'.
%
% NOTE: This is not the most conservative assumption to avoid collisions. In
% particular this make an assumption that robots move uniformly and edges are
% at least the a robot's width apart.
% ------------------------------------------------------------------------------

&diff{ arrive(P,V'') - arrive(P',V') } <= 0  :- before((P,V),(P',V')), move(P,V,V'').

% ------------------------------------------------------------------------------
% Task completion dependency check. When some robot R finishes task T (at V)
% then robot R' has at least kappa time to finish executing T' (at V'). Note:
% exit(T,V) doesn't force the robot to actually leave the node. That only
% happens at exit(T'',V) for the subsequent task T'' in robot R's task/path
% sequence.
% ------------------------------------------------------------------------------

&diff{ exit(T,V) - exit(T',V')} <= -kappa  :- depends(D,T,T'), D != deliver,
                                              task(T,V), task(T',V').




% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------


