% ------------------------------------------------------------------------------
% Common code for sequencing tasks that have been assigned to robots. Note: this
% is now separate from the assignment code so that we can look at different
% sequencing mechanisms.
%
% Note: this code by itself doesn't generate proper sequences and relies on the
% DL timing constraints to enforce proper sequencing. In particular without the
% DL constraints we can have: 1) a robot with a cyclic task_sequence (provided
% there is also a non-cyclic task sequence for that robot), 2) wait dependencies
% are not guaranteed to be satisfied (both for wait dependencies assigned to the
% same robot and for wait dependencies assigned between different robots).
%
% Input facts: robot/1, tasks/2, same_robot/2, assignment/2.
% Output facts: task_sequence/2
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Don't choose pickup-putdown sequences since they are completely determined by
% the pickup.  Make sure each robot with assignments has a linear task sequences
% are linear (see note above that there could still be a secondary cyclic task
% sequence).
% ------------------------------------------------------------------------------

0 { task_sequence(T,T') : task(T',_), not depends(deliver,_,T'), T != T' } 1 :-
                          task(T,_), not depends(deliver,T,_).
task_sequence(T,T')     :- depends(deliver,T,T').


:- task_sequence(T,T'), not same_robot(T,T'), not same_robot(T',T).

%:- task_sequence(T,T'), task_sequence(T',T).             % Stop trivial cycles
%:- task_sequence(T,T'), task_sequence(T,T''), T' < T''.  % Enforced by the sequence choice rule

:- task_sequence(T',T), task_sequence(T'',T), T' < T''.
:- task(T,_), not task_sequence(T,_), not task_sequence(_,T).

:- robot(R), #count{ T : assignment(R,T), not task_sequence(_,T) } > 1.

% I think this is redundant????
:- assignment(R,_),
   #false : assignment(R,T), task_sequence(T,_), not task_sequence(_,T).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
