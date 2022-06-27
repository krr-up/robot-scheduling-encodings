%!flags! --heuristic=Domain
%!desc! Task sequence acyclicity, path move sequence acyclicity, corridor limited moves, lower-bounds, and move heuristics ("1,sign" shortest path and "1,false" otherwise)
% ------------------------------------------------------------------------------
% The "fast" path encoding with no options.
% ------------------------------------------------------------------------------

#include "path/show_basic.lp".

#include "common/task_assignment.lp".
#include "common/task_sequencing.lp".
#include "common/task_sequencing_acyclic.lp".
#include "common/task_sequencing_global_acyclic.lp".

#include "path/task_to_path.lp".

#include "path/corr_strict.lp".
#include "path/move_choice_corr.lp".

#include "path/move_sequencing.lp".
#include "path/move_sequencing_acyclic.lp".

#include "path/visit_ordering.lp".

#include "path/path_encoding.lp".

#include "path/path_encoding_lb.lp".

#include "path/move_choice_corr_heur_nf.lp".

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

