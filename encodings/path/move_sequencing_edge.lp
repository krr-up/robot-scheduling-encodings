% ------------------------------------------------------------------------------
% Question is does the move sequencing allow extra circular paths when there
% also exists a linear path. tests/instances/unsat6.lp seems to confirm that
% this is not the case but I haven't convinced myself why this should be the
% case. So adding this extra #edge constraint to see if it makes any difference
% to the solving.
% ------------------------------------------------------------------------------

#edge((P,V),(P,V')) : move(P,V,V').

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

