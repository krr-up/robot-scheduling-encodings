% ------------------------------------------------------------------------------
% Choose a projection for each robot that assigns step-vertex visits to tasks.
%
% Inputs: robot/1, task/2, step/1, assignment/2, task_sequence/2, walk/3.
%
% Output: proj/2.
%
% Note: robot/1, task/2, and step/1 are domain predicates.
%
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Choose a set of projections and make sure the assignment and projection set is
% executable: Definitions 8 and 9. Note: only one projection per robot, per step
% is allowed.
% ------------------------------------------------------------------------------

%1 { proj(T,S) : step(S) } 1  :- task(T,V).

:- proj(T,S), task(T,V), assignment(R,T), not walk(R,S,V).
:- proj(T,S), proj(T',S'), task_sequence(T,T'), S > S'.

:- #count{ T : proj(T,S), assignment(R,T) } > 1, step(S), robot(R).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

