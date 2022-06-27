edge(w1,w2,15).
edge(w1,w3,15).
edge(w3,w1,15).
edge(w2,w1,15).








conflict(w1,w1).
conflict(w3,w3).
conflict(w2,w2).
task(t1,w2).
task(t2,w3).
home(r1,w1).
start(r1,w1).
robot(r1).
depends(deliver,t1,t2).
shortest_path(w2,w3,30,w1).
shortest_path(w2,w1,15,w1).
shortest_path(w3,w2,30,w1).
shortest_path(w3,w1,15,w1).
shortest_path(w1,w2,15,w2).
shortest_path(w1,w3,15,w3).

