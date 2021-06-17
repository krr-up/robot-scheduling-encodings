% ----------------------------------------------------------------------------
% Turn path encoding output into a walk output.
%
% Output facts:
% - assignment(Robot,Task)
% - walk(Robot,Step,Vertex)
% - proj(Task,Step)
% - dl(Variable,Value)
%
% ----------------------------------------------------------------------------

% ---------------------------------------------------------------------------------
% Count the number of vertices visited for each path
% ---------------------------------------------------------------------------------

path_visits(P,N) :- visit(P,_), N = #count{ V : visit(P,V) }.

active_path(P) :- visit(P,_), #count{ V : visit(P,V) } > 1.

%---------------------------------------------------------------------------------
% For each robot that has to move (ie it has assignments or has to return home)
% assign a sequence count to each path.
% ---------------------------------------------------------------------------------

task_num(R,T,0)    :- assignment(R,T), task_sequence(T,_), not task_sequence(_,T).
task_num(R,T',N+1) :- task_num(R,T,N), task_sequence(T,T').

path_num(R,T,N)   :- task_num(R,T,N).
path_num(R,R,N+1) :- task_num(R,_,N), #false : task_num(R,_,N'), N < N'.

path_num(R,R,0) :- start(R,V), home(R,V'), V != V', not assignment(R,_).


% ---------------------------------------------------------------------------------
% Active paths are paths that involve movement (ie visit more than one vertex)
% ---------------------------------------------------------------------------------

path_chain(R,N,N') :-  path_num(R,P,N), active_path(P),
                       path_num(R,P',N'), active_path(P'), N < N',
                       #false : path_num(R,P'',X), active_path(P''),
                                N < X, X < N'.

apath_num(R,P,0)     :- path_num(R,P,N), active_path(P), not path_chain(R,_,N).
apath_num(R,P',N+1)  :- apath_num(R,P,N), path_num(R,P',N'), path_chain(R,N,N').


apath_steps(R,P,0,N-1)     :- apath_num(R,P,0), path_visits(P,N).
apath_steps(R,P',E,E+V-1)  :- apath_num(R,P,N), apath_steps(R,P,B,E),
                              apath_num(R,P',N+1), path_visits(P',V).

% ---------------------------------------------------------------------------------
% Turn each move(P,V,V') into a walk(R,S,V)
% ---------------------------------------------------------------------------------


path_walk(R,P,B,V)    :- apath_steps(R,P,B,_), move(P,V,_), not move(P,_,V).
path_walk(R,P,S+1,V') :- apath_steps(R,P,B,E), path_walk(R,P,S,V), move(P,V,V').

walk(R,S,V) :- path_walk(R,_,S,V).

proj(T,E) :- apath_steps(R,T,B,E), task(T,_).

% ---------------------------------------------------------------------------------
% Build the projections
% ---------------------------------------------------------------------------------

walk_arrive(R,S,V,T) :- dl(arrive(P,V),T), path_walk(R,P,S,V),
                        #false : path_walk(R,P',S,V), P' != P.
walk_arrive(R,S,V,T) :- dl(arrive(P,V),T), path_walk(R,P,S,V),
                        path_walk(R,P',S,V), path_num(R,P,N), path_num(R,P',M), N < M.

walk_exit(R,S,V,T)   :- dl(exit(P,V),T), path_walk(R,P,S,V),
                        #false : path_walk(R,P',S,V), P' != P.
walk_exit(R,S,V,T)   :- dl(exit(P,V),T), path_walk(R,P,S,V),
                        path_walk(R,P',S,V), path_num(R,P,N), path_num(R,P',M), N > M.

walk(R,S,V,T,T')     :- walk_arrive(R,S,V,T), walk_exit(R,S,V,T').

walk(R,S,V,T,T'-D)   :- walk_arrive(R,S,V,T), not walk_exit(R,S,V,_),
                        walk_arrive(R,S+1,V',T'), edge(V,V',D).
walk(R,S,V,T,T')     :- walk_arrive(R,S,V,T), not walk_exit(R,S,V,_),
                        not walk_arrive(R,S+1,_,_), dl(bound,T').

% ---------------------------------------------------------------------------------

% ---------------------------------------------------------------------------------

#show.
%#show move/3.
%#show path_num/3.
%#show path_visits/2.
%#show active_path/1.
%#show path_chain/3.
%#show apath_num/3.
%#show visit/2.
%#show apath_steps/4.
%#show path_walk/4.
%#show walk/5.

#show assignment/2.
#show walk/3.
#show proj/2.
#show dl/2.

