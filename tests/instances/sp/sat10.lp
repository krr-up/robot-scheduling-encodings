edge(w1,w2,15).
edge(w2,w5,15).
edge(w3,w4,15).
edge(w4,w5,15).
edge(w5,w6,15).
edge(w6,w7,15).
edge(w7,w6,15).
edge(w6,w5,15).
edge(w5,w4,15).
edge(w4,w3,15).
edge(w5,w2,15).
edge(w2,w1,15).

























conflict(w1,w1).
conflict(w2,w2).
conflict(w3,w3).
conflict(w4,w4).
conflict(w5,w5).
conflict(w6,w6).
conflict(w7,w7).







home(r1,w7).
home(r2,w6).
start(r1,w1).
start(r2,w3).
robot(r1).
robot(r2).
shortest_path(w1,w7,60,w2).
shortest_path(w1,w6,45,w2).
shortest_path(w3,w7,60,w4).
shortest_path(w3,w6,45,w4).
shortest_path(w4,w6,30,w5).
shortest_path(w4,w7,45,w5).
shortest_path(w2,w6,30,w5).
shortest_path(w2,w7,45,w5).
shortest_path(w5,w7,30,w6).
shortest_path(w5,w6,15,w6).
shortest_path(w6,w7,15,w7).

