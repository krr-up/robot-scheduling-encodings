% ------------------------------------------------------------------------------
% Make sure the move sequence visits the required path vertices in the correct
% order; and if a robot is unassigned and has no paths then it doesn't move.
%
% Inputs: move/3, start/2, path/2, path_assignment/2, path_sequence/2.
% Outputs: first_visit/2. last_visit/2.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Define the first and last visit based on the moves
% ------------------------------------------------------------------------------

first_visit(P,V) :- move(P,V,_), not move(P,_,V).
last_visit(P,V) :-  move(P,_,V), not move(P,V,_).

% Special case if a robot is already at its path destination
last_visit(P,V) :- path(P,V), not move(P,_,_).
first_visit(P,V) :- path(P,V), not move(P,_,_).

% ------------------------------------------------------------------------------
% Because the move choices ensure that for any vertex connected to a path there
% can be at most one incoming edge and at most one outgoing edge, we therefore
% only need to look at the last vertex visited to ensure that a path is a single
% unbroken sequence that ends at the appropriate vertex.
% ------------------------------------------------------------------------------

:- #count{ V : last_visit(P,V) } > 1, path(P,_).
:- path(P,V), not last_visit(P,V).

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
% For a robot with nothing to do (so it starts at its home vertex and has no
% assignments) - there should be no moves to or from its home vertex.
% ------------------------------------------------------------------------------

%:- start(R,V), not path(R,_), visit(_,V).

:- start(R,V), not path(R,_), move(_,V,_).
:- start(R,V), not path(R,_), move(_,_,V).



% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

