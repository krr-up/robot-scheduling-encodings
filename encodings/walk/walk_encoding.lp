% ------------------------------------------------------------------------------
% A faithful/direct encoding of the problem formalisation in terms of a walk for
% each robot that visits the required task nodes in an appropriate order.
% ------------------------------------------------------------------------------

encoding(walk).

% ------------------------------------------------------------------------------
% Assign tasks to robots and generate a task sequence for each robot.
% ------------------------------------------------------------------------------

%#include "common/task_sequencing.lp".
%#include "common/task_sequencing_heur1.lp".


% ------------------------------------------------------------------------------
% Construct the walk for each robot
% ------------------------------------------------------------------------------

%#include "walk/step_choice.lp".

% ------------------------------------------------------------------------------
% To assign times to each robot's walk we calculate the time that each robot
% arrives and exits the vertex associated with each step.
% ------------------------------------------------------------------------------

% Cannot exit a vertex before you arrive at it. Travel time must satisfy the
% edge weight.

%% NOTE: Robots arrive at their starting location at time 0 (otherwise could
%%have late appearing robots).

&diff{ arrive(R,0) - 0 } <= 0               :- walk(R,0,_).
&diff{ 0 - arrive(R,0) } <= 0               :- walk(R,0,_).

&diff{ arrive(R,S) - exit(R,S) } <= 0       :- walk(R,S,_).

&diff{ exit(R,S) - arrive(R,S+1) } <= -W    :- walk(R,S,V), walk(R,S+1,V'),
                                               edge(V,V',W).
% Returning home before some bound.
&diff{ arrive(R,S) - bound } <= 0      :- walk(R,S,V), not walk(R,S+1,_).

% Robot "exits" its destination node at the time bound
%&diff{ arrive(R,S) - exit(R,S) } <= 0  :- walk(R,S,_), not walk(R,S+1,_).

&diff{ exit(R,S) - bound } <= 0        :- walk(R,S,_), not walk(R,S+1,_).
&diff{ bound - exit(R,S) } <= 0        :- walk(R,S,_), not walk(R,S+1,_).


% ------------------------------------------------------------------------------
% Collision free assignment based on ordering visits to vertices for each robot.
% ------------------------------------------------------------------------------

%#include "walk/step_ordering.lp".

% ------------------------------------------------------------------------------
% A before B. NOTE: We are modelling a vertex as taking up some space that is
% enough to contain a robot. Therefore we can have a robot exit a node at the
% same instance that another robot arrives at that node. But we are also
% allowing a robot to arrive and exit a node at the same instant. This creates a
% problem that before(v,(R,S),(R',S')) allows R and R' to both arrive and exit
% the node at the same instant without violating the constraint. We could add a
% delay between arriving and exiting, but instead make sure two robots cannot
% arrive at the same time.
% ------------------------------------------------------------------------------

&diff{ arrive(R,S) - arrive(R',S') } <= -1  :- before(v,(R,S),(R',S')).
&diff{ exit(R,S) - arrive(R',S') } <= 0     :- before(v,(R,S),(R',S')).

% ------------------------------------------------------------------------------
% Two cases for edge conflicts that are not subsumed by the vertex conflicts.
% ------------------------------------------------------------------------------

&diff{ arrive(R,S+1) - exit(R',S') } <= 0  :-
                                       before(v,(R,S+1),(R',S'+1)),
                                       walk(R,S,V1), walk(R,S+1,V2),
                                       walk(R',S',V1'), walk(R',S'+1,V2'),
                                       conflict(e,(V1,V2),(V1',V2')).

&diff{ arrive(R,S+1) - exit(R',S') } <= 0  :-
                                       before(v,(R,S),(R',S'+1)),
                                       walk(R,S,V1), walk(R,S+1,V2),
                                       walk(R',S',V1'), walk(R',S'+1,V2'),
                                       conflict(e,(V1,V2),(V1',V2')).






%%%&diff{ arrive(R,S+1) - exit(R',S') } <= 0   :- before(e,(R,S),(R',S')).

% ------------------------------------------------------------------------------
% Choose a set of projections
% ------------------------------------------------------------------------------

%#include "walk/projection_choice.lp".

% ------------------------------------------------------------------------------
% Timing based on the projection points
% ------------------------------------------------------------------------------
#const epsilon=10.

&diff{ arrive(R,S) - exit(R,S) } <= -epsilon  :- proj(T,S), assignment(R,T).
&diff{ exit(R',S') - exit(R,S) } <= 0         :- proj(T,S), assignment(R,T),
                                                 proj(T',S'), assignment(R',T'),
                                                 depends(_,T',T).


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

