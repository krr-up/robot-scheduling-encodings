%!flags! --heuristic=Domain
% ------------------------------------------------------------------------------
% The "fast" path encoding with no options.
% ------------------------------------------------------------------------------

#include "path/show.lp".

#include "common/task_assignment.lp".
#include "common/task_sequencing_direct.lp".

#include "path/task_to_path.lp".

#include "path/move_choice_corr.lp".

#include "path/move_sequencing.lp".

#include "path/visit_ordering.lp".

#include "path/visit_tracker_tight.lp".

#include "path/fast_encoding.lp".

#include "path/fast_encoding_lb.lp".

#include "path/move_corr_heur2.lp".

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

