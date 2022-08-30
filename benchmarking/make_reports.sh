XML_DATA_DIR=juggling-xml-data
EVAL_XML=${XML_DATA_DIR}/juggling-eval.xml
REPORTS_DIR=reports
mkdir -p $REPORTS_DIR

#measures="time:t,timeout:t,choices:t,conflicts:t,time_grounding:t,dl_edges:t,dl_variables:t"
measures="time:t,timeout:t,maxstep:t"

#measures="time:t,timeout:t,memout,choices:t,conflicts:t,time_grounding:t,time_solve:t,dl_edges:t,dl_variables:t,maxstep:t,replacement_count:t,replacement_max:t,replacement_geomean:t"

ods(){
    bconv --projects="clingo-walksoln-job" --measures=${measures} ${EVAL_XML} > ${REPORTS_DIR}/walk-first-soln.ods
    bconv --projects="clingo-onesoln-job" --measures=${measures} ${EVAL_XML} > ${REPORTS_DIR}/path-first-soln.ods
    bconv --projects="clingo-goodsoln-job" --measures=${measures} ${EVAL_XML} > ${REPORTS_DIR}/path-repl-time-soln.ods
    bconv --projects="clingo-bestsoln-job" --measures=${measures} ${EVAL_XML} > ${REPORTS_DIR}/path-opt-soln.ods
}
ods


