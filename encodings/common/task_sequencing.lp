% ------------------------------------------------------------------------------
% Common code for sequencing tasks that have been assigned to robots. Note: this
% is now separate from the assignment code so that we can look at different
% sequencing mechanisms.
%
% For any robot with a task we want to enforce that there must be exactly one
% linear task sequence.
%
% Note: however, the following code by itself doesn't generate proper sequences
% and relies on the DL timing constraints (or some othere cyclicity detection)
% to enforce proper sequencing. In particular without the DL constraints we can
% have: 1) a robot with a one or more cyclic task_sequences (provided there is
% also a non-cyclic task sequence for that robot), 2) wait dependencies are not
% guaranteed to be satisfied (both for wait dependencies assigned to the same
% robot and for wait dependencies assigned between different robots).
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

0 { task_sequence(T,T') : task(T',_), T != T', not depends(deliver,_,T') } 1 :-
                                            task(T,_), not depends(deliver,T,_).
task_sequence(T,T')                                 :- depends(deliver,T,T').

:- task_sequence(T,T'),
   not same_robot(T,T'), not same_robot(T',T), not depends(deliver,T,T').

% Make sure a task can't have more than one predecessor.

:- task(T,_), 2 #count{ T' : task_sequence(T',T) }.

% Each assigned robot must have exactly one linear sequence; hence must have
% only a single first task.  Note: could have some cyclic sequences as well but
% we don't prevent that here.

:- assignment(R,_), not #count{ T : assignment(R,T), not task_sequence(_,T) } = 1.


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
