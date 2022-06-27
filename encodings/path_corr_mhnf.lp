%!flags! --heuristic=Domain
%!desc! Corridor limited moves, and move heuristic
% ------------------------------------------------------------------------------
% The "fast" path encoding with no options.
% ------------------------------------------------------------------------------

#include "path/show_basic.lp".

#include "common/task_assignment.lp".
#include "common/task_sequencing.lp".

#include "path/task_to_path.lp".

#include "path/corr_strict.lp".
#include "path/move_choice_corr.lp".

#include "path/move_sequencing.lp".

#include "path/visit_ordering.lp".

#include "path/path_encoding.lp".

#include "path/move_choice_corr_heur_nf.lp".

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

