% ------------------------------------------------------------------------------
% When robots visit conflicting vertices pick who goes first.
%
% Inputs: conflict/3, walk/3.
%
%
% ------------------------------------------------------------------------------

% R visits a vertex at step S before R' visits its vertex at step S'
{ before(v,(R,S),(R',S')) }   :- walk(R,S,V), walk(R',S',V'),
                                 conflict(v,V,V'), R < R'.
before(v,(R',S'),(R,S))       :- walk(R,S,V), walk(R',S',V'),
                                 conflict(v,V,V'), R < R',
                                 not before(v,(R,S),(R',S')).

% Start of walk must arrive first and end of walk must arrive last
:- walk(R,0,_), before(v,(_,_),(R,0)).
:- walk(R,S,_), not walk(R,S+1,_), before(v,(R,S),(_,_)).


%:- walk(R,0,_), before(e,(_,_),(R,0)).
%:- walk(R,S,_), not walk(R,S+1,_), before(e,(R,S),(_,_)).



% ------------------------------------------------------------------------------
% Make sure there are no swap or overtaking actions
% ------------------------------------------------------------------------------

% Prevent robots that are moving in the same direction from overtaking. If two
% robot move in the same directions over two nodes then one robot must complete
% both moves before the other.
:- walk(R,S,V1), walk(R,S+1,V2), walk(R',S',V1'), walk(R',S'+1,V2'),
   conflict(v,V1,V1'), conflict(v,V2,V2'), before(v,(R,S),(R',S')),
   not before(v,(R,S+1),(R',S'+1)).

% Prevent robots that are moving in the opposite direction from swapping. If two
% robot move in opposite directions over two nodes then one robot must complete
% both moves before the other.
:- walk(R,S,V1), walk(R,S+1,V2), walk(R',S',V1'), walk(R',S'+1,V2'),
   conflict(v,V1,V2'), conflict(v,V2,V1'), before(v,(R,S),(R',S'+1)),
   not before(v,(R,S+1),(R',S')).


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------




%%:- walk(R1,S1,V1), walk(R1,S1+1,V1'), walk(R2,S2,V2), walk(R2,S2+1,V2'),
%%   conflict(v,V1,V2'), conflict(v,V1',V2), before(v,(R1,S1),(R2,S2+1)),
%%   not before(v,(R1,S1+1),(R2,S2)).




%%:- walk(R1,S1,V1), walk(R1,S1+1,V1'), walk(R2,S2,V2), walk(R2,S2+1,V2'),
%%   conflict(v,V1,V2), conflict(v,V1',V2'), before(v,(R1,S1),(R2,S2)),
%%   not before(v,(R1,S1+1),(R2,S2+1)).



% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------



%%before(e,(R,S),(R',S'))  :-  walk(R,S,V1), walk(R,S+1,V2),
%%                             walk(R',S',V1'), walk(R',S'+1,V2'),
%%                             conflict(e,(V1,V2),(V1',V2')),
%%                             before(v,(R,S),(R',S')).
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

