% ------------------------------------------------------------------------------
% Extra constraints that don't changed the semantics (ie doesn't limit the
% search space) but may help with solving.
% ------------------------------------------------------------------------------


%&diff{ 0 - arrive(T,V) } <= 0   :- task(T,_), start(_,V).
%&diff{ 0 - arrive(P,V) } <= 0   :- visit(P,V).

% ------------------------------------------------------------------------------
% The putdown of a delivery task must happen after the pickup. Because a
% delivery is performed by the same robot this is already enforced by the task
% sequence.
% ------------------------------------------------------------------------------

&diff{ arrive(T,V) - arrive(T',V')} <= 0  :- depends(deliver,T,T'),
                                             task(T,V), task(T',V').


%%&diff{ arrive(P,V'') - arrive(T',V')} <= 0  :- depends(wait,T,T'),
%%                                               task(T,V), task(T',V'),
%%                                               path_sequence(T,P), move(P,V,V'').



% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

