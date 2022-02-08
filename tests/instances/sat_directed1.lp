%------------------------------------------------------------------------------
% Example with a directed graph. Robot has to do a loop to get home.
%
%            w2
%          /    \
% (r1:s) w1      w3
%               /
%     (r1:e) w4
%
% Robots with tasks to pickup/putdown at opposite ends
%------------------------------------------------------------------------------

edge(w1,w2,15).
edge(w2,w3,15).
edge(w3,w4,15).

robot(r1). start(r1,w1). home(r1,w4).

task(t1,w2). task(t2,w3).

depends(deliver,t1,t2).

conflict(V,V;V',V')       :- edge(V,V',_).
conflict(Y,X)              :- conflict(X,Y).

%#minimize{ S : walk(R,S,_), not walk(R,S+1,_) }. % Walk DL

