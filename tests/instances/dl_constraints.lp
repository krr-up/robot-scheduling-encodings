% ------------------------------------------------------------------------------
%
% Enforces difference logic constraints based on some input facts:
%
% dl_eq(Variable, Value) - Variable must be equal to Value
% dl_le(Variable, Value) - Variable must be less than or equal to Value
% dl_ge(Variable, Value) - Variable must be greater than or equal to Value
%
% ------------------------------------------------------------------------------

dl_le(Var,Val) :- dl_eq(Var,Val).
dl_ge(Var,Val) :- dl_eq(Var,Val).

&diff{ Var - 0 } <= Value :- dl_le(Var,Value).
&diff{ 0 - Var } <= -Value :- dl_ge(Var,Value).




