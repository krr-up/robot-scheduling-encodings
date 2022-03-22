% ------------------------------------------------------------------------------
% A pure ASP handling to make sure that the dependency between non-delivery
% tasks is maintained. In particular that wait dependencies are satisfied (both
% within a single robot assignment and between robot assignments).
%
% This is an additional constraint to the task_sequencing_acyclic constraint
% that ensures a linear task sequence.
%
% NOTE: as with the base task sequencing acyclicty constraint, this constraint
% is redundant when the DL timing constraints are added.
%
% Use clingo #edge for cycle detection
%
% Input facts: depends/2.
% ------------------------------------------------------------------------------

#edge(T,T') : depends(D,T,T'), D != deliver.


% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
