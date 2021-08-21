% ------------------------------------------------------------------------------
% Extra constraints for determining the before/3 instances. This don't changed
% the semantics (ie doesn't limit the search space) but may help with solving.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% If P visit V before P' visit V' then any previous path to P that visit's V
% will do so before P' visits V'. Similarly with any task after P' will visit V'
% after P visits V. This will eventually be enforced by the DL constraints but
% we can also determine it in pure ASP.
% ------------------------------------------------------------------------------

path_seqnum(R,0)    :- path_assignment(R,R), not assignment(R,_).
path_seqnum(P,0)    :- path_sequence(P,_), not path_sequence(_,P).
path_seqnum(P',N+1) :- path_seqnum(P,N), path_sequence(P,P'),
                       #count{ 1 : task(_,_) } = TN, N <= TN.

:- before((P,V),(P',V')), path_assignment(R,P), path_assignment(R,P''),
   path_seqnum(P,N), path_seqnum(P'',M), M < N, visit(P'',V),
   not before((P'',V),(P',V')).

:- before((P,V),(P',V')), path_assignment(R,P'), path_assignment(R,P''),
   path_seqnum(P',M), path_seqnum(P'',N), M < N, visit(P'',V'),
   not before((P,V),(P'',V')).

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

