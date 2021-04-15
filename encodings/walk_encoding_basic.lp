% ------------------------------------------------------------------------------
% Fase encoding with all options enabled.
% ------------------------------------------------------------------------------

#include "task_sequencing.lp".
#include "walk_encoding.lp".

% ------------------------------------------------------------------------------
% Show for post-processing to generate the plan
% ------------------------------------------------------------------------------


#show task/2.
#show assignment/2.
#show task_sequence/2.
#show walk/3.
#show proj/2.

%#show before/3.
%#show same_walk/2.

%#show shortest_path/4.
%#show on_minpath/3.
%#show path_min_dist/2.

% ------------------------------------------------------------------------------
% Show for post-processing for the solution checker
% ------------------------------------------------------------------------------

#show depends/3.
#show conflict/3.
#show edge/3.
#show start/2.
#show home/2.

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

