% ------------------------------------------------------------------------------
% Extra constraints that don't changed the semantics (ie doesn't limit the
% search space) but may help with solving.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Explicitly enforce some of the orderings for paths visiting a vertex. NOTE:
% this will also be enforced by the DL constraints, so does this help with
% solving? It has a significant impact on grounding.
% ------------------------------------------------------------------------------

%:- before(v,(P,V),(P',V')), path_assignment(R,P), path_seqnum(P,N),
%   visit(P'',V), path_assignment(R,P''), path_seqnum(P'',N''), N'' < N,
%   not before(v,(P'',V),(P',V')).


%&diff{ 0 - arrive(T,V) } <= 0   :- task(T,_), start(_,V).
%&diff{ 0 - arrive(P,V) } <= 0   :- visit(P,V).



% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

