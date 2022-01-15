%!flags! --heuristic=Domain
%!desc! Task sequence acyclicity, corridor limited moves, lower bounds, and move heuristic ("1,sign" shortest path and "-1,sign" otherwise)
% ------------------------------------------------------------------------------
% The "fast" path encoding with no options.
% ------------------------------------------------------------------------------

#include "path/show_basic.lp".

#include "common/task_assignment.lp".
#include "common/task_sequencing_direct.lp".
#include "common/task_sequencing_acyclic.lp".

#include "path/task_to_path.lp".

#include "path/move_choice_corr.lp".

#include "path/move_sequencing.lp".

#include "path/visit_ordering.lp".

#include "path/path_encoding.lp".

#include "path/path_encoding_lb.lp".

#include "path/move_choice_corr_heur_ss.lp".

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

