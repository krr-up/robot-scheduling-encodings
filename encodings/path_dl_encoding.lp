% ------------------------------------------------------------------------------
% Robot task sequence asssignment: Definition 4(i) + Definition 5
% ------------------------------------------------------------------------------

% BUG clingo-dl is not checking relative path so for the moment have to include
% task_sequencing.lp from the command line.
%#include "task_sequencing.lp".

% ------------------------------------------------------------------------------
% Partial merging of Definition 4(ii) + Definition 6 (except 6(iii)) +
% Definitions 8 and 9.
%
% Generate an acyclic path for each task that ends at the tasks action
% vertex. Then match the first and last vertex visits to task sequences and
% robot start positions. No need for a separate projection set because we track
% task paths so know exactly when the task ends.
% ------------------------------------------------------------------------------

0 { move(T,V,V') : edge(V,V',_) } 1 :- task(T,_), edge(V,_,_).
0 { move(T,V,V') : edge(V,V',_) } 1 :- task(T,_), edge(V',_,_).

first_visit(T,V) :- move(T,V,_), not move(T,_,V).
last_visit(T,V) :-  move(T,_,V), not move(T,V,_).

:- #count{ V : first_visit(T,V) } > 1, task(T,_).
:- #count{ V : last_visit(T,V) } > 1, task(T,_).
:- last_visit(T,V), not task(T,V).

visit(T,V)   :- first_visit(T,V).
visit(T,V')  :- visit(T,V), move(T,V,V').

:- task_sequence(T,_), not task_sequence(_,T),
   assignment(R,T), start(R,V), not first_visit(T,V).
:- task_sequence(T,T'), task(T,V), not first_visit(T',V).

% ------------------------------------------------------------------------------
% Travel times must satisfy edge weights and cannot leave a vertex before
% arriving at it. Also create a 0 time transition between the end of one task
% and the start of the next task in a task sequence.
% ------------------------------------------------------------------------------

#const epsilon=10.

&diff{ arrive(T,V) - exit(T,V) } <= 0        :- visit(T,V), not task(T,V).
&diff{ arrive(T,V) - exit(T,V) } <= -epsilon :- visit(T,V), task(T,V).
&diff{ exit(T,V) - arrive(T,V') } <= -W      :- move(T,V,V'), edge(V,V',W).

&diff{ arrive(T',V) - exit(T,V) } <= 0       :- task_sequence(T,T'), task(T,V).
&diff{ exit(T,V) - arrive(T',V) } <= 0       :- task_sequence(T,T'), task(T,V).


% ------------------------------------------------------------------------------
% Definition 7
%
% Deal with conflicts but only for the tasks assigned to the different robots
% ------------------------------------------------------------------------------

{ before(v,(T,V),(T',V')) }   :- visit(T,V), visit(T',V'),
                                 conflict(v,V,V'), T < T',
                                 not same_robot(T,T'),
                                 not same_robot(T',T).
before(v,(T',V'),(T,V))       :- visit(T,V), visit(T',V'),
                                 conflict(v,V,V'), T < T',
                                 not same_robot(T,T'),
                                 not same_robot(T',T),
                                 not before(v,(T,V),(T',V')).

{ before(e,(T,V2),(T',V1')) } :- move(T,V1,V2), move(T',V1',V2'),
                                 conflict(e,(V1,V2),(V1',V2')), T < T',
                                 not same_robot(T,T'),
                                 not same_robot(T',T).
before(e,(T',V1'),(T,V2))     :- move(T,V1,V2), move(T',V1',V2'),
                                 conflict(e,(V1,V2),(V1',V2')), T < T',
                                 not same_robot(T,T'),
                                 not same_robot(T',T),
                                 not before(e,(T,V2),(T',V1')).




&diff{ exit(T,V) - arrive(T',V') } <= -1  :- before(v,(T,V),(T',V')).
&diff{ arrive(T,V) - exit(T',V') } <= -1  :- before(e,(T,V),(T',V')).

% ------------------------------------------------------------------------------
% Partial Definitions 9.
%
% Assignment dependency checking.
% ------------------------------------------------------------------------------

&diff{ arrive(T,V) - arrive(T',V')} <= 0  :- depends(_,T,T'),
                                             task(T,V), task(T',V').

:- depends(deliver,T,T'), not task_sequence(T,T').
:- depends(deliver,T,T'), assignment(R,T), not assignment(R,T').
:- depends(deliver,T,T'), assignment(R,T'), not assignment(R,T).

% ------------------------------------------------------------------------------
% Show for post-processing
% ------------------------------------------------------------------------------


#show task/2.
#show assignment/2.
#show task_sequence/2.
#show visit/2.
#show move/3.

#show before/3.
