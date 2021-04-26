% ------------------------------------------------------------------------------
% To debug difference logic we need to set the value of variables. Do this based
% on a predicate dlf(Var,Val) that forces variable Var to be value Val.
% ------------------------------------------------------------------------------


&diff{ 0 - Var } <= -Value :- dlf(Var,Value).
&diff{ Var - 0 } <= Value :- dlf(Var,Value).

#defined dlf/2.
#show dlf/2.



