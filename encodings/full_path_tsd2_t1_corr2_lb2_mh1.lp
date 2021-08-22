%!flags! --heuristic=Domain --configuration=handy
% ------------------------------------------------------------------------------
% The "fast" path encoding with no options.
% ------------------------------------------------------------------------------
% Modified after think tank


#include "path/show.lp".

#include "common/task_assignment.lp".
#include "common/task_sequencing_direct2.lp".
#include "common/task_sequencing_extra_edge.lp".

#include "path/task_to_path.lp".

#include "path/move_choice_corr2.lp".

#include "path/move_sequencing.lp".

#include "path/visit_ordering.lp".

#include "path/visit_tracker_tight.lp".

#include "path/full_encoding.lp".

#include "path/full_encoding_extra_lb2.lp".

#include "path/move_corr2_heur1.lp".

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

