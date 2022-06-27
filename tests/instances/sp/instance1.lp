edge(l1,w1,15).
edge(l2,w2,15).
edge(p1,w3,15).
edge(h1,w4,15).
edge(h2,w5,15).
edge(w1,w2,20).
edge(w2,w3,20).
edge(w3,w4,30).
edge(w4,w5,20).
edge(w1,w12,15).
edge(w2,w11,16).
edge(w2,w10,18).
edge(w3,w9,15).
edge(w4,w8,18).
edge(w4,w7,15).
edge(w5,w6,15).
edge(w12,w11,10).
edge(w11,w10,10).
edge(w9,w8,20).
edge(w8,w7,10).
edge(w7,w6,20).
edge(w12,s1,15).
edge(w11,s2,15).
edge(w10,s3,15).
edge(w9,s4,15).
edge(w8,s5,15).
edge(w7,s6,15).
edge(s6,w7,15).
edge(s5,w8,15).
edge(s4,w9,15).
edge(s3,w10,15).
edge(s2,w11,15).
edge(s1,w12,15).
edge(w6,w7,20).
edge(w7,w8,10).
edge(w8,w9,20).
edge(w10,w11,10).
edge(w11,w12,10).
edge(w6,w5,15).
edge(w7,w4,15).
edge(w8,w4,18).
edge(w9,w3,15).
edge(w10,w2,18).
edge(w11,w2,16).
edge(w12,w1,15).
edge(w5,w4,20).
edge(w4,w3,30).
edge(w3,w2,20).
edge(w2,w1,20).
edge(w5,h2,15).
edge(w4,h1,15).
edge(w3,p1,15).
edge(w2,l2,15).
edge(w1,l1,15).
conflict(s1,s2).
conflict(s3,s4).
conflict(s5,s6).
conflict(w12,w11).
conflict(w10,w9).
conflict(w8,w7).















































































































conflict(l1,l1).
conflict(l2,l2).
conflict(p1,p1).
conflict(h1,h1).
conflict(h2,h2).
conflict(w1,w1).
conflict(w2,w2).
conflict(w3,w3).
conflict(w4,w4).
conflict(w5,w5).
conflict(w12,w12).
conflict(w11,w11).
conflict(w9,w9).
conflict(w8,w8).
conflict(w7,w7).
conflict(w10,w10).
conflict(s6,s6).
conflict(s5,s5).
conflict(s4,s4).
conflict(s3,s3).
conflict(s2,s2).
conflict(s1,s1).
conflict(w6,w6).














conflict(w7,w8).
conflict(w9,w10).
conflict(w11,w12).
conflict(s6,s5).
conflict(s4,s3).
conflict(s2,s1).















task(t1,l1).
task(t2,s2).
task(t3,p1).
task(t4,l1).
task(t5,l2).
task(t6,s1).
task(t7,p1).
task(t8,l2).
home(r1,h1).
home(r2,h2).
start(r1,h1).
start(r2,h2).
robot(r1).
robot(r2).
depends(deliver,t1,t2).
depends(deliver,t3,t4).
depends(wait,t1,t4).
depends(deliver,t5,t6).
depends(deliver,t7,t8).
depends(wait,t5,t8).
shortest_path(l1,s2,55,w1).
shortest_path(l1,p1,70,w1).
shortest_path(l1,l2,50,w1).
shortest_path(l1,s1,45,w1).
shortest_path(l1,h1,100,w1).
shortest_path(l1,h2,120,w1).
shortest_path(s2,l1,55,w11).
shortest_path(s2,p1,66,w11).
shortest_path(s2,l2,46,w11).
shortest_path(s2,s1,40,w11).
shortest_path(s2,h1,96,w11).
shortest_path(s2,h2,116,w11).
shortest_path(p1,l1,70,w3).
shortest_path(p1,s2,66,w3).
shortest_path(p1,l2,50,w3).
shortest_path(p1,s1,76,w3).
shortest_path(p1,h1,60,w3).
shortest_path(p1,h2,80,w3).
shortest_path(l2,l1,50,w2).
shortest_path(l2,s2,46,w2).
shortest_path(l2,p1,50,w2).
shortest_path(l2,s1,56,w2).
shortest_path(l2,h1,80,w2).
shortest_path(l2,h2,100,w2).
shortest_path(s1,l1,45,w12).
shortest_path(s1,s2,40,w12).
shortest_path(s1,p1,76,w12).
shortest_path(s1,l2,56,w12).
shortest_path(s1,h1,106,w12).
shortest_path(s1,h2,126,w12).
shortest_path(h1,l1,100,w4).
shortest_path(h1,s2,96,w4).
shortest_path(h1,p1,60,w4).
shortest_path(h1,l2,80,w4).
shortest_path(h1,s1,106,w4).
shortest_path(h1,h2,50,w4).
shortest_path(h2,l1,120,w5).
shortest_path(h2,s2,116,w5).
shortest_path(h2,p1,80,w5).
shortest_path(h2,l2,100,w5).
shortest_path(h2,s1,126,w5).
shortest_path(h2,h1,50,w5).
shortest_path(w5,h1,35,w4).
shortest_path(w5,s1,111,w4).
shortest_path(w5,l2,85,w4).
shortest_path(w5,p1,65,w4).
shortest_path(w5,s2,101,w4).
shortest_path(w5,l1,105,w4).
shortest_path(w4,h2,35,w5).
shortest_path(w4,s1,91,w3).
shortest_path(w4,l2,65,w3).
shortest_path(w4,p1,45,w3).
shortest_path(w4,s2,81,w3).
shortest_path(w4,l1,85,w3).
shortest_path(w12,h2,111,w11).
shortest_path(w12,h1,91,w11).
shortest_path(w12,l2,41,w11).
shortest_path(w12,p1,61,w11).
shortest_path(w12,s2,25,w11).
shortest_path(w12,l1,30,w1).
shortest_path(w2,h2,85,w3).
shortest_path(w2,h1,65,w3).
shortest_path(w2,s1,41,w11).
shortest_path(w2,p1,35,w3).
shortest_path(w2,s2,31,w11).
shortest_path(w2,l1,35,w1).
shortest_path(w3,h2,65,w4).
shortest_path(w3,h1,45,w4).
shortest_path(w3,s1,61,w2).
shortest_path(w3,l2,35,w2).
shortest_path(w3,s2,51,w2).
shortest_path(w3,l1,55,w2).
shortest_path(w11,h2,101,w2).
shortest_path(w11,h1,81,w2).
shortest_path(w11,s1,25,w12).
shortest_path(w11,l2,31,w2).
shortest_path(w11,p1,51,w2).
shortest_path(w11,l1,40,w12).
shortest_path(w1,h2,105,w2).
shortest_path(w1,h1,85,w2).
shortest_path(w1,s1,30,w12).
shortest_path(w1,l2,35,w2).
shortest_path(w1,p1,55,w2).
shortest_path(w1,s2,40,w12).
shortest_path(w2,l2,15,l2).
shortest_path(w12,s1,15,s1).
shortest_path(w4,h1,15,h1).
shortest_path(w1,l1,15,l1).
shortest_path(w11,s2,15,s2).
shortest_path(w3,p1,15,p1).
shortest_path(w5,h2,15,h2).

