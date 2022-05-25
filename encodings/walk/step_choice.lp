% ------------------------------------------------------------------------------
% Choose the steps in each robots walk.
%
% Inputs: assignment/2, edge/3, robot/1, start/2, home/2.
%
% Outputs: walk/3.
%
% Note: all except assignment/2 are domain predicates.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% NOTE: 'maxstep' must be defined in the instance or on the command line
% #const maxstep=10.
% ------------------------------------------------------------------------------
step(0..maxstep).

vertex(V) :- edge(V,_,_).
vertex(V) :- edge(_,V,_).

0 { walk(R,S,V) : vertex(V) } 1 :- robot(R), step(S).

% The walk forms a sequence that starts at the robot's current position and ends
% at the robot's home position.
:- walk(R,S,_), not walk(R,S-1,_), S>0.
:- walk(R,0,V), not start(R,V).
:- walk(R,S,V), walk(R,S+1,V'), not edge(V,V',_).
:- walk(R,S,V), not walk(R,S+1,_), not home(R,V).

:- start(R,V), home(R,V'), V != V', not walk(R,_,_).

% An assigned robot must at least visit the task vertex. This will already be
% impossed by the projection.
% :- assignment(R,T), task(T,V), not walk(R,_,V).

% For a robot that doesn't move - no other robot can access that vertex
:- start(R,V), not walk(R,_,_), walk(_,_,V).

% Note: a robot that is at home and has no assignments could still be required
% to move to get out of the way in order to let another robot to pass.  Because
% of this we DON'T want a constraint like the following: ":- start(R,V),
% home(R,V), walk(R,_,_), not assignment(R,_)."

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

