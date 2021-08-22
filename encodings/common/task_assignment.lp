% ------------------------------------------------------------------------------
% Common code for assigning tasks to robots. Note: the task assignment and task
% sequencing are now separated since the task sequencing can be performed in
% different ways.
%
% Input facts: robot/1, tasks/2.
% Output facts: assignment/2.
% Auxilary output facts: same_robot/2.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% This version improves grounding - don't choose putdown task assignments since
% they are completely determined by the pickup assignments. Similarly same_robot
% is completely determined for pickup-putdown pairs.
% ------------------------------------------------------------------------------

1 { assignment(R,T) : robot(R) } 1 :- task(T,_), not depends(deliver,_,T).
assignment(R,T')                   :- assignment(R,T), depends(deliver,T,T').

same_robot(T,T')  :- assignment(R,T), assignment(R,T'), T < T',
                     not depends(deliver,T,T').
same_robot(T,T')  :- depends(deliver,T,T').



% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
