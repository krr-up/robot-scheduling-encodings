%!flags! --heuristic=Domain
%!desc! Phillip W's task sequencing selection with task sequence acyclicty, corridor limited moves, lower bounds, and move heuristic
% ------------------------------------------------------------------------------
% The "fast" path encoding with no options.
% ------------------------------------------------------------------------------
% Modified after think tank


#include "path/show_basic.lp".

#include "common/task_assignment.lp".
#include "common/task_sequencing_direct2.lp".
#include "common/task_sequencing_acyclic.lp".

#include "path/task_to_path.lp".

#include "path/move_choice_corr.lp".

#include "path/move_sequencing.lp".

#include "path/visit_ordering.lp".

#include "path/path_encoding.lp".

#include "path/path_encoding_lb.lp".

#include "path/move_choice_corr_heur.lp".

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

