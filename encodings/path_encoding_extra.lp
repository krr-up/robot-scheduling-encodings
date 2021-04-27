% ------------------------------------------------------------------------------
% Extra constraints that don't changed the semantics (ie doesn't limit the
% search space) but may help with solving.
% ------------------------------------------------------------------------------

% Ensure that the transition from one task to the next is exactly 0 duration

&diff{ arrive(P',V) - exit(P,V) } <= 0       :- path_sequence(P,P'), path(P,V).

% This is needed if we want to minimize the bound - otherwise it generates
% negative arrival times.
%%%&diff{ 0 - arrive(P,V) } <= 0          :- visit(P,V).


% ------------------------------------------------------------------------------
% If P visit V before P' visit V' then and previous path to P that visit's V
% will do so before P' visits V'. Similarly with any task after P' will visit V'
% after P visits V. This is enforced by the DL constraints.
% ------------------------------------------------------------------------------

path_seqnum(R,0)    :- path_assignment(R,R), not assignment(R,_).
path_seqnum(P,0)    :- path_sequence(P,_), not path_sequence(_,P).
path_seqnum(P',N+1) :- path_seqnum(P,N), path_sequence(P,P'),
                       #count{ 1 : task(_,_) } = TN, N <= TN.

:- before(v,(P,V),(P',V')), path_assignment(R,P), path_assignment(R,P''),
   path_seqnum(P,N), path_seqnum(P'',M), M < N, visit(P'',V),
   not before(v,(P'',V),(P',V')).

% ------------------------------------------------------------------------------
% The putdown of a delivery task must happen after the pickup. Because a
% delivery is performed by the same robot this is already enforced by the task
% sequence.
% ------------------------------------------------------------------------------

&diff{ exit(T,V) - arrive(T',V')} <= 0  :- depends(deliver,T,T'),
                                           task(T,V), task(T',V').


%%&diff{ arrive(P,V'') - arrive(T',V')} <= 0  :- depends(wait,T,T'),
%%                                               task(T,V), task(T',V'),
%%                                               path_sequence(T,P), move(P,V,V'').



% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

