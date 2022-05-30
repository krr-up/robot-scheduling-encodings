% ------------------------------------------------------------------------------
% A faithful/direct encoding of the problem formalisation in terms of a walk for
% each robot that visits the required task nodes in an appropriate order.
% ------------------------------------------------------------------------------

encoding(walk).

% ------------------------------------------------------------------------------
% Assign tasks to robots and generate a task sequence for each robot.
% ------------------------------------------------------------------------------

%#include "common/task_assignment.lp".
%#include "common/task_sequencing.lp".

% ------------------------------------------------------------------------------
% Construct the walk for each robot
% ------------------------------------------------------------------------------

%#include "walk/step_choice.lp".

% ------------------------------------------------------------------------------
% To assign times to each robot's walk we calculate the time that each robot
% arrives and exits the vertex associated with each step.
% ------------------------------------------------------------------------------

% Robots arrive at their starting location at time 0 (otherwise we could have
% late appearing robots).
&diff{ arrive(R,0) - 0 } <= 0               :- walk(R,0,_).
&diff{ 0 - arrive(R,0) } <= 0               :- walk(R,0,_).

% A robot must arrive before it exits a vertex
&diff{ arrive(R,S) - exit(R,S) } <= 0       :- walk(R,S,_).

% The edge weight is the travel time between vertecies
&diff{ exit(R,S) - arrive(R,S+1) } <= -W    :- walk(R,S,V), walk(R,S+1,V'),
                                               edge(V,V',W).
% Returning home before some bound.
&diff{ arrive(R,S) - bound } <= 0      :- walk(R,S,_), not walk(R,S+1,_).

% Robot "exits" its destination node at the time bound
&diff{ exit(R,S) - bound } <= 0        :- walk(R,S,_), not walk(R,S+1,_).
&diff{ bound - exit(R,S) } <= 0        :- walk(R,S,_), not walk(R,S+1,_).


% ------------------------------------------------------------------------------
% Collision free assignment based on ordering visits to vertices for each robot.
% ------------------------------------------------------------------------------

%#include "walk/step_ordering.lp".

% ------------------------------------------------------------------------------
% A before B. NOTE: We are modelling a vertex as a point (and therefore taking
% up no space). So we can have a robot arrive and exit a vertex at the same
% instant. Because of this if robot A is at vertex V and moves to vertex V', we
% ensure that A arrives at V' no later than B arrives at V. So only one robot
% can be on an edge at the same time.
% ------------------------------------------------------------------------------

&diff{ arrive(R,S+1) - arrive(R',S') } <= 0 :- before((R,S),(R',S')).

% ------------------------------------------------------------------------------
% Choose a set of projections
% ------------------------------------------------------------------------------

%#include "walk/projection_choice.lp".

% ------------------------------------------------------------------------------
% Timing based on the projection points
% ------------------------------------------------------------------------------
#const kappa=10.

&diff{ arrive(R,S) - exit(R,S) } <= -kappa  :- proj(T,S), assignment(R,T).

&diff{ arrive(R,S) - arrive(R',S') } <= -kappa  :- proj(T,S), assignment(R,T),
                                                   proj(T',S'), assignment(R',T'),
                                                   depends(D,T,T'), D != deliver,
                                                   R != R'.


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

