%------------------------------------------------------------------------------
%
%                            ll1-...-ll5
%                           / |       | \
%                         l1  |   X   |  l2
%                        /  \ |       | /  \
%                       /    lm1-...-lm5    \
% (r1:s) (r1:h) m1--- m2      |   X   |      m3
%                       \    rm1-...-rm5    /
%                        \  / |       | \  /
%                         r1  |   X   |  r2
%                           \ |       | /
%                            rr1-...-rr5
%
%
% Test the move heuristic. Robot starts at m1, picks up item at m2 and delivers
% it to m3 (then goes home back to m1). There are 4 shortest paths from m2 to m3
% and the robot has to do two trips along these paths.
%
% Ideally for each trip the robot should pick a single shortest path and stick
% to it. But the heuristic that simply rules out every node that's not on a
% shortest path will allow the robot to snake its way across all 4 shortest
% paths.
%
%------------------------------------------------------------------------------
#include "graph_rules.lp".

% Edges of the shortest paths
              edge(ll1,ll2,20). edge(ll2,ll3,20). edge(ll3,ll4,20). edge(ll4,ll5,20).
          edge(l1,ll1,30).                                                edge(ll5,l2,30).
     edge(m2,l1,30).                                                           edge(l2,m3,30).
          edge(l1,lm1,30).                                                edge(lm5,l2,30).
              edge(lm1,lm2,20). edge(lm2,lm3,20). edge(lm3,lm4,20). edge(lm4,lm5,20).
edge(m1,m2,15).                                                                     edge(m3,m4,30).
              edge(rm1,rm2,20). edge(rm2,rm3,20). edge(rm3,rm4,20). edge(rm4,rm5,20).
          edge(r1,rm1,30).                                                edge(rm5,r2,30).
     edge(m2,r1,30).                                                           edge(r2,m3,30).
          edge(r1,rr1,30).                                                edge(rr5,r2,30).
              edge(rr1,rr2,20). edge(rr2,rr3,20). edge(rr3,rr4,20). edge(rr4,rr5,20).

% Extra edges to allow crossing between shortest paths
edge(ll1,lm1,10). edge(ll2,lm2,10). edge(ll3,lm3,10). edge(ll4,lm4,10). edge(ll5,lm5,10).
edge(lm1,rm1,10). edge(lm2,rm2,10). edge(lm3,rm3,10). edge(lm4,rm4,10). edge(lm5,rm5,10).
edge(rm1,rr1,10). edge(rm2,rr2,10). edge(rm3,rr3,10). edge(rm4,rr4,10). edge(rm5,rr5,10).

edge(ll1,lm2,25). edge(ll2,lm3,25). edge(ll3,lm4,25). edge(ll4,lm5,25).
edge(lm1,ll2,25). edge(lm2,ll3,25). edge(lm3,ll4,25). edge(lm4,ll5,25).
edge(lm1,rm2,25). edge(lm2,rm3,25). edge(lm3,rm4,25). edge(lm4,rm5,25).
edge(rm1,lm2,25). edge(rm2,lm3,25). edge(rm3,lm4,25). edge(rm4,lm5,25).
edge(rm1,rr2,25). edge(rm2,rr3,25). edge(rm3,rr4,25). edge(rm4,rr5,25).
edge(rr1,rm2,25). edge(rr2,rm3,25). edge(rr3,rm4,25). edge(rr4,rm5,25).


robot(r1). start(r1,m1). home(r1,m1).

task(t1,m2). task(t2,m3).
depends(deliver,t1,t2).

