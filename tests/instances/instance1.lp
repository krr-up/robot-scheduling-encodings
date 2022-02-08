% ------------------------------------------------------------------------------
% Example from the paper
% ------------------------------------------------------------------------------

#include "graph_rules.lp".

edge(l1,w1,15).   edge(l2,w2,15).
edge(p1,w3,15).   edge(h1,w4,15).
edge(h2,w5,15).   edge(w1,w2,20).
edge(w2,w3,20).   edge(w3,w4,30).
edge(w4,w5,20).   edge(w1,w12,15).
edge(w2,w11,16).  edge(w2,w10,18).
edge(w3,w9,15).   edge(w4,w8,18).
edge(w4,w7,15).   edge(w5,w6,15).
edge(w12,w11,10). edge(w11,w10,10).
edge(w9,w8,20).   edge(w8,w7,10).
edge(w7,w6,20).   edge(w12,s1,15).
edge(w11,s2,15).  edge(w10,s3,15).
edge(w9,s4,15).   edge(w8,s5,15).
edge(w7,s6,15).

edge(V',V,W) :- edge(V,V',W).


robot(r1). home(r1,h1).  start(r1,h1).
robot(r2). home(r2,h2).  start(r2,h2).

conflict(V,V;V',V')   :- edge(V,V',_).


conflict(R',R)          :- conflict(R,R').

conflict(s1,s2).    conflict(s3,s4).
conflict(s5,s6).    conflict(w12,w11).
conflict(w10,w9).   conflict(w8,w7).





task(t1,l1). task(t2,s2).
task(t3,p1). task(t4,l1).
task(t5,l2). task(t6,s1).
task(t7,p1). task(t8,l2).

depends(deliver,t1,t2).
depends(deliver,t3,t4).
depends(wait,t1,t4).
depends(deliver,t5,t6).
depends(deliver,t7,t8).
depends(wait,t5,t8).

