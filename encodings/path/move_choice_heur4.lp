% ------------------------------------------------------------------------------
% Domain heuristics for improving move selection based on precomputed shortest
% path relations.
% ------------------------------------------------------------------------------

#include "move_choice_minpath.lp".

% Higher factor values for vertices on the minpath the closer they are to the
% start or end of a path.
factor(P,Cur,|X-X'|)     :- on_minpath(P,Cur,_), first_visit(P,Src), last_visit(P,Dst),
                            shortest_path(Cur,Dst,X,_), shortest_path(Cur,Src,X',_).

% The first move of the robot towards a path
%first_move(R,Src,V)  :- start(R,Src), not path_sequence(_,R), path(R,Dst),
%                        shortest_path(Src,Dst,_,V).

%first_move(P,Src,V)  :- path_sequence(P',P), path(P',Src), path(P,Dst),
%                        shortest_path(Src,Dst,_,V).

%#heuristic move(R,Src,V) : first_move(R,Src,V). [1,sign]
%#heuristic move(R,Src,V) : first_move(R,Src,V). [2,factor]

#heuristic move(P,V,V')  : on_minpath(P,V,V').                              [1,sign]
#heuristic move(P,V,V')  : on_minpath(P,V,V'), factor(P,V,X).               [X,init]

#heuristic move(P,V,V')  : on_minpath(P,V,V'), factor(P,V,X).               [X,true]
#heuristic move(P,V,V')  : path(P,_), edge(V,V',_), not on_minpath(P,V,V'). [1,false]


#heuristic move(P,V',V'')  : move(P,V,V'), path(P,Dst),
                             shortest_path(V',Dst,X,V'').                   [2,factor]






% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

