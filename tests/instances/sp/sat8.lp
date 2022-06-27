edge(w1,w2,15).
edge(w2,w4,15).
edge(w1,w3,15).
edge(w3,w4,15).
edge(w4,w3,15).
edge(w3,w1,15).
edge(w4,w2,15).
edge(w2,w1,15).
















conflict(w1,w1).
conflict(w2,w2).
conflict(w3,w3).
conflict(w4,w4).
task(t1,w1).
task(t2,w4).
task(t3,w4).
task(t4,w1).
home(r1,w1).
home(r2,w4).
start(r1,w1).
start(r2,w4).
robot(r1).
robot(r2).
depends(deliver,t1,t2).
depends(deliver,t3,t4).
shortest_path(w1,w4,30,w2).
shortest_path(w1,w4,30,w3).
shortest_path(w4,w1,30,w3).
shortest_path(w4,w1,30,w2).
shortest_path(w2,w1,15,w1).
shortest_path(w3,w1,15,w1).
shortest_path(w3,w4,15,w4).
shortest_path(w2,w4,15,w4).

