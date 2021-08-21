% ------------------------------------------------------------------------------
% Fix a time bound for the time between a delivery pickup and replacement
% putdown item. This establishes a quality requirement on the solution.
%
% Input: depends(wait,T,T'), task(T,V).
%
% Output: sets DL constraints
% ------------------------------------------------------------------------------

% Note: we don't have a precise notion of time. But treating 10 time points as 1
% second. So 2 minutes is:
#const repl_time=2*600.

% NOTE: strictly speaking I'm not sure this captures the semantics of what is
% meant by the replacement time. The start time should be the earliest time that
% a robot has picked up the item, and the end time should be the time that a
% robot has putdown the item. The end time could also more correctly be the time
% that the robot that has putdown the item has had enough time to move to the
% next vertex (because only then can some arm robot putdown a new item for
% delivery). However, at least for the moment, only looking at the arrival times
% seems like a good enough simplification. It works for both the full and fast
% encodings and is fully grounded.

&diff{ arrive(T',V') - arrive(T,V) } <= repl_time :-
                                    depends(wait,T,T'), task(T,V), task(T',V').



% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

