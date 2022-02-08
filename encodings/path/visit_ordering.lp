% ------------------------------------------------------------------------------
% Decide the order in which different robots visit a given vertex (as part of a
% given path) to ensure a conflict free ordering.
%
% Input: same_robot/2, assignment/2, path_assignment/2, conflict/3,
%        start/2, path/2, move/3,
%
% Output: before/3, same_walk/2 (auxiliary).
%
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Track the vertices that are visited for each path.
% ------------------------------------------------------------------------------

visit(P,V) :- move(P,V,_).
visit(P,V) :- path(P,V).

% ------------------------------------------------------------------------------
% Need to explicitly track the paths that are assigned to different robots
% since we only need to order between two paths if they are part of the walks
% for different robots.
% ------------------------------------------------------------------------------

same_walk(T,T')                :- same_robot(T,T').
same_walk(T',T)                :- same_robot(T,T').
same_walk(R,T)                 :- assignment(R,T).

% P visits V before P' visit V'
{ before((P,V),(P',V')) }    :- visit(P,V), visit(P',V'),
                                conflict(V,V'), P < P',
                                not same_walk(P,P').
before((P',V'),(P,V))        :- visit(P,V), visit(P',V'),
                                conflict(V,V'), P < P',
                                not same_walk(P,P'),
                                not before((P,V),(P',V')).

% The start of a robot's walk must be first at the starting vertex (there are
% two cases: robot with/without an assignment)
:- start(R,V), path(R,_), not assignment(R,_), before((_,_),(R,V)).
:- start(R,V), path_assignment(R,P),
   path_sequence(P,_), not path_sequence(_,P), before((_,_),(P,V)).

% The end of a robot's walk must arrive at its destination last
:- robot(R), path(R,V), before((R,V),(_,_)).

% Ensure the transition between two paths is reflected in the before/3 relation
:- before((P,V),(P',V')), path(P,V), path_sequence(P,P''),
   not before((P'',V),(P',V')).

% ------------------------------------------------------------------------------
% Track successive moves to make sure there are no swap or overtaking actions
% ------------------------------------------------------------------------------

% Prevent robots that are moving in the same direction from overtaking. If two
% robot move in the same directions over two nodes then one robot must complete
% both moves before the other.
:- move(P,V1,V2), move(P',V1',V2'),
   conflict(V1,V1'), conflict(V2,V2'), before((P,V1),(P',V1')),
   not before((P,V2),(P',V2')).


% Prevent robots that are moving in the opposite direction from swapping. If two
% robot move in opposite directions over two nodes then one robot must complete
% both moves before the other.
:- move(P,V1,V2), move(P',V1',V2'),
   conflict(V1,V2'), conflict(V2,V1'), before((P,V1),(P',V2')),
   not before((P,V2),(P',V1')).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

