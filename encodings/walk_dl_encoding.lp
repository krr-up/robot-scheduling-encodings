% ------------------------------------------------------------------------------
% Robot task sequence asssignment: Definition 4(i) + Definition 5
% ------------------------------------------------------------------------------

#include "task_sequencing.lp".

% ------------------------------------------------------------------------------
% Robot timed walk assignment: Definition 4(ii) + Definition 6 (except 6(iii)).
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% NOTE: 'maxstep' must be defined in the instance or on the command line
% #const maxstep=10.
% ------------------------------------------------------------------------------
step(0..maxstep).

0 { walk(R,S,V) : edge(V,_,_) } 1 :- robot(R), step(S).

:- walk(R,S,_), not walk(R,S-1,_), S>0.

:- walk(R,0,V), not start(R,V).
:- walk(R,S,V), walk(R,S+1,V'), not edge(V,V',_).
:- walk(R,S,V), not walk(R,S+1,_), not home(R,V).

:- start(R,V), home(R,V'), V != V', not walk(R,_,_).

% For a robot with no walk - no other robot can access that vertex
:- start(R,V), not walk(R,_,_), walk(_,_,V).

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

{ before(v, (R,S),(R',S')) }   :- walk(R,S,V), walk(R',S',V'),
                                  conflict(v,V,V'), R < R'.
before(v, (R',S'),(R,S))       :- walk(R,S,V), walk(R',S',V'),
                                  conflict(v,V,V'), R < R',
                                  not before(v,(R,S),(R',S')).

{ before(e,(R,S),(R',S')) } :-  walk(R,S,V1), walk(R,S+1,V2),
                                walk(R',S',V1'), walk(R',S'+1,V2'),
                                conflict(e,(V1,V2),(V1',V2')), R < R'.
before(e,(R',S'),(R,S))     :-  walk(R,S,V1), walk(R,S+1,V2),
                                walk(R',S',V1'), walk(R',S'+1,V2'),
                                conflict(e,(V1,V2),(V1',V2')), R < R',
                                not before(e,(R,S),(R',S')).


% Start of walk must arrive first and end of walk must arrive last
:- walk(R,0,_), before(v,(_,_),(R,0)).
:- walk(R,0,_), before(e,(_,_),(R,0)).
:- walk(R,S,_), not walk(R,S+1,_), before(v,(R,S),(_,_)).
:- walk(R,S,_), not walk(R,S+1,_), before(e,(R,S),(_,_)).

% arrival at vertices connected to conflicted edges must be consistent.
%:- walk(R1,S1,V1), walk(R1,S1+1,V1'), walk(R2,S2,V2), walk(R2,S2+1,V2'),
%   conflict(e,(V1,V1'),(V2,V2')), before(e,(R1,S1),(R2,S2)),
%   not before(v,(R1,S1+1),(R2,S2+1)).
%:- walk(R1,S1,V1), walk(R1,S1+1,V1'), walk(R2,S2,V2), walk(R2,S2+1,V2'),
%   conflict(e,(V1,V1'),(V2,V2')), before(v,(R1,S1),(R2,S2)),
%   not before(v,(R1,S1),(R2,S2)).



&diff{ exit(R,S) - arrive(R',S') } <= -1  :- before(v,(R,S),(R',S')).
&diff{ arrive(R,S+1) - exit(R',S') } <= -1  :- before(e,(R,S),(R',S')).

% ------------------------------------------------------------------------------
% Choose a set of projections and make sure the assignment and projection set is
% executable: Definitions 8 and 9. Note: only one projection per robot, per step
% is allowed.
% ------------------------------------------------------------------------------

#const epsilon=10.

1 { proj(T,S) : step(S) } 1  :- task(T,V).

:- proj(T,S), task(T,V), assignment(R,T), not walk(R,S,V).
:- proj(T,S), proj(T',S'), task_sequence(T,T'), S > S'.

:- #count{ T : proj(T,S), assignment(R,T) } > 1, step(S), robot(R).

&diff{ arrive(R,S) - exit(R,S) } <= -epsilon  :- proj(T,S), assignment(R,T).
&diff{ exit(R',S') - exit(R,S) } <= 0         :- proj(T,S), assignment(R,T),
                                                 proj(T',S'), assignment(R',T'),
                                                 depends(_,T',T).


% ------------------------------------------------------------------------------
% Show for post-processing
% ------------------------------------------------------------------------------


#show task/2.
#show assignment/2.
#show task_sequence/2.
#show walk/3.
#show proj/2.
#show before/3.
