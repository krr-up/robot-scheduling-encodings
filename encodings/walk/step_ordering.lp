% ------------------------------------------------------------------------------
% When robots visit conflicting vertices pick who goes first.
%
% Inputs: conflict/3, walk/3.
%
%
% ------------------------------------------------------------------------------

% R visits a vertex at step S before R' visits its vertex at step S'
{ before((R,S),(R',S')) }   :- walk(R,S,V), walk(R',S',V'),
                                 conflict(V,V'), R < R'.
before((R',S'),(R,S))       :- walk(R,S,V), walk(R',S',V'),
                                 conflict(V,V'), R < R',
                                 not before((R,S),(R',S')).

% Start of walk must arrive first and end of walk must arrive last
:- walk(R,0,_), before((_,_),(R,0)).
:- walk(R,S,_), not walk(R,S+1,_), before((R,S),(_,_)).


% ------------------------------------------------------------------------------
% Make sure there are no swap or overtaking actions
% ------------------------------------------------------------------------------

% Prevent robots that are moving in the same direction from overtaking. If two
% robot move in the same directions over two nodes then one robot must complete
% both moves before the other.
:- walk(R,S,V1), walk(R,S+1,V2), walk(R',S',V1'), walk(R',S'+1,V2'),
   conflict(V1,V1'), conflict(V2,V2'), before((R,S),(R',S')),
   not before((R,S+1),(R',S'+1)).

% Prevent robots that are moving in the opposite direction from swapping. If two
% robot move in opposite directions over two nodes then one robot must complete
% both moves before the other.
:- walk(R,S,V1), walk(R,S+1,V2), walk(R',S',V1'), walk(R',S'+1,V2'),
   conflict(V1,V2'), conflict(V2,V1'), before((R,S),(R',S'+1)),
   not before((R,S+1),(R',S')).


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

