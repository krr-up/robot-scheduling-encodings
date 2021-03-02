% ------------------------------------------------------------------------------
% Robot task sequence asssignment: Definition 4(i) + Definition 5
% ------------------------------------------------------------------------------

% BUG clingo-dl is not checking relative path so for the moment have to include
% task_sequencing.lp from the command line.
%#include "task_sequencing.lp".

% ------------------------------------------------------------------------------
% Robot timed walk assignment: Definition 4(ii) + Definition 6 (except 6(iii)).
% ------------------------------------------------------------------------------

#const maxstep=20.
step(0..maxstep).

0 { walk(R,S,V) : edge(V,_,_) } 1 :- robot(R), step(S).

:- walk(R,S,_), not walk(R,S-1,_), S>0.

:- walk(R,0,V), not start(R,V).
:- walk(R,S,V), walk(R,S+1,V'), not edge(V,V',_).
:- walk(R,S,V), not walk(R,S+1,_), not home(R,V).

% Cannot exit a vertex before you arrive at it. Travel time must satisfy the
% edge weight.

&diff{ 0 - arrive(R,0) } <= 0 :- walk(R,0,_).
&diff{ arrive(R,0) - 0 } <= 0 :- walk(R,0,_).
&diff{ arrive(R,S) - exit(R,S) } <= 0          :- walk(R,S,_).

&diff{ exit(R,S) - arrive(R,S+1) } <= -W      :- walk(R,S,V), walk(R,S+1,V'),
                                                      edge(V,V',W).

% ------------------------------------------------------------------------------
% Collision free: Definition 7
% ------------------------------------------------------------------------------

{ before(v, (R,S),(R',S')) } :- walk(R,S,V), walk(R',S',V'),
                                conflict(v,V,V'), R < R'.
before(v, (R',S'),(R,S))     :- walk(R,S,V), walk(R',S',V'),
                                conflict(v,V,V'), R < R',
                                not before(v,(R,S),(R',S')).

{ before(e,(R,S),(R',S')) } :-  walk(R,S,V1), walk(R,S+1,V2),
                                walk(R',S',V1'), walk(R',S'+1,V2'),
                                conflict(e,(V1,V2),(V1',V2')), R < R'.
before(e,(R',S'),(R,S))     :-  walk(R,S,V1), walk(R,S+1,V2),
                                walk(R',S',V1'), walk(R',S'+1,V2'),
                                conflict(e,(V1,V2),(V1',V2')), R < R',
                                not before(e,(R,S),(R',S')).

&diff{ exit(R,S) - arrive(R',S') } <= -1  :- before(v,(R,S),(R',S')).
&diff{ arrive(R,S+1) - exit(R',S') } <= -1  :- before(e,(R,S),(R',S')).

% ------------------------------------------------------------------------------
% Choose a set of projections and make sure the assignment and projection set is
% executable: Definitions 8 and 9.
% ------------------------------------------------------------------------------

#const epsilon=10.

1 { proj(T,S) : step(S) } 1  :- task(T,V).

:- proj(T,S), task(T,V), assignment(R,T), not walk(R,S,V).
:- proj(T,S), proj(T',S'), task_sequence(T,T'), S > S'.

&diff{ arrive(R,S) - exit(R,S) } <= -epsilon  :- proj(T,S), assignment(R,T).
&diff{ exit(R',S') - exit(R,S) } <= 0         :- proj(T,S), assignment(R,T),
                                                 proj(T',S'), assignment(R',T'),
                                                 depends(_,T',T).

:- depends(deliver,T,T'), not task_sequence(T,T').
:- depends(deliver,T,T'), assignment(R,T), not assignment(R,T').
:- depends(deliver,T,T'), assignment(R,T'), not assignment(R,T).


% ------------------------------------------------------------------------------
% Show for post-processing
% ------------------------------------------------------------------------------


#show task/2.
#show assignment/2.
#show task_sequence/2.
#show walk/3.
#show proj/2.
#show before/3.
