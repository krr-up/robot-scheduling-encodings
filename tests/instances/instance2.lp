% ------------------------------------------------------------------------------
% Example from the paper
% ------------------------------------------------------------------------------

#include "graph_rules.lp".

edge(l2,w2,15).
edge(p1,w3,15).   edge(h1,w4,15).
edge(w2,w3,20).   edge(w3,w4,30).
edge(w2,w11,16).  edge(w2,w10,18).
edge(w3,w9,15).   edge(w4,w8,18).
edge(w11,w10,10).
edge(w9,w8,20).
edge(w11,s2,15).

edge(V',V,W) :- edge(V,V',W).

robot(r1). home(r1,h1).  start(r1,h1).

conflict(V,V;V',V')   :- edge(V,V',_).


conflict(R',R)          :- conflict(R,R').

conflict(w10,w9).

task(t1,l2). task(t2,s2).
task(t3,p1). task(t4,l2).

depends(deliver,t1,t2).
depends(deliver,t3,t4).

