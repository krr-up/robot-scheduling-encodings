%!flags! --heuristic=Domain
%!desc! Task sequence acyclicty, corridor limited moves, use lower bounds, move heuristic, and bounded replacement time between item pickup and replacement empty pallet putdown
% ------------------------------------------------------------------------------
% The "fast" path encoding with no options.
% ------------------------------------------------------------------------------

#include "path/show_basic.lp".

#include "common/task_assignment.lp".
#include "common/task_sequencing.lp".
#include "common/task_sequencing_acyclic.lp".

#include "path/task_to_path.lp".

#include "path/move_choice_corr.lp".

#include "path/move_sequencing.lp".
#include "path/move_sequencing_acyclic.lp".

#include "path/visit_ordering.lp".

#include "path/path_encoding.lp".

#include "path/path_encoding_lb.lp".

#include "path/replacement_time_bound.lp".

#include "path/move_choice_corr_heur_nf.lp".

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

