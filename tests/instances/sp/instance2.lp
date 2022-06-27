edge(l2,w2,15).
edge(p1,w3,15).
edge(h1,w4,15).
edge(w2,w3,20).
edge(w3,w4,30).
edge(w2,w11,16).
edge(w2,w10,18).
edge(w3,w9,15).
edge(w4,w8,18).
edge(w11,w10,10).
edge(w9,w8,20).
edge(w11,s2,15).
edge(s2,w11,15).
edge(w8,w9,20).
edge(w10,w11,10).
edge(w8,w4,18).
edge(w9,w3,15).
edge(w10,w2,18).
edge(w11,w2,16).
edge(w4,w3,30).
edge(w3,w2,20).
edge(w4,h1,15).
edge(w3,p1,15).
edge(w2,l2,15).
conflict(w10,w9).
















































conflict(l2,l2).
conflict(p1,p1).
conflict(h1,h1).
conflict(w2,w2).
conflict(w3,w3).
conflict(w4,w4).
conflict(w11,w11).
conflict(w9,w9).
conflict(s2,s2).
conflict(w8,w8).
conflict(w10,w10).
conflict(w9,w10).
task(t1,l2).
task(t2,s2).
%task(t3,p1).
%task(t4,l2).
home(r1,h1).
start(r1,h1).
robot(r1).
depends(deliver,t1,t2).
%depends(deliver,t3,t4).
shortest_path(h1,l2,80,w4).
shortest_path(h1,s2,96,w4).
shortest_path(h1,p1,60,w4).
shortest_path(l2,s2,46,w2).
shortest_path(l2,p1,50,w2).
shortest_path(l2,h1,80,w2).
shortest_path(s2,l2,46,w11).
shortest_path(s2,p1,66,w11).
shortest_path(s2,h1,96,w11).
shortest_path(p1,l2,50,w3).
shortest_path(p1,s2,66,w3).
shortest_path(p1,h1,60,w3).
shortest_path(w3,h1,45,w4).
shortest_path(w3,s2,51,w2).
shortest_path(w3,l2,35,w2).
shortest_path(w11,h1,81,w2).
shortest_path(w11,p1,51,w2).
shortest_path(w11,l2,31,w2).
shortest_path(w2,h1,65,w3).
shortest_path(w2,p1,35,w3).
shortest_path(w2,s2,31,w11).
shortest_path(w4,p1,45,w3).
shortest_path(w4,s2,81,w3).
shortest_path(w4,l2,65,w3).
shortest_path(w3,p1,15,p1).
shortest_path(w11,s2,15,s2).
shortest_path(w2,l2,15,l2).
shortest_path(w4,h1,15,h1).

