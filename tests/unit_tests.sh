#!/usr/bin/env bash

WALK_DL="walk"
PATH_DL="path"
FAST_DL="fast"

CLINGODLFACTS="../scripts/clingo-dl-facts.sh"
CLINGOFACTS="../scripts/clingo-facts.sh"
CLINGODL="clingo-dl"

#------------------------------------------------------------------
# Check that a problem is unsatisfiable
#------------------------------------------------------------------

check_unsat() {
    local base="$1"
    local instance="$2"
    local encoding="../encodings/${base}_encoding_basic.lp"
    shift ; shift

    RESULT=$($CLINGODL $encoding $instance $@ 2>/dev/null | sed -e 's/^.*\(UNSATISFIABLE\).*/BLAH/;t;d')
    if [ "$RESULT" != "BLAH" ] ; then
        echo "Error: \"clingo-dl $encoding $instance\" is satisfiable"
    fi
}

#------------------------------------------------------------------
# Check that a problem is satisfiable
#------------------------------------------------------------------

check_sat() {
    local base="$1"
    local instance="$2"
    local encoding="../encodings/${base}_encoding_basic.lp"
    shift ; shift

#    echo "RUNNING: clingo-dl $encoding $instance"
    RESULT=$($CLINGODL $encoding $instance $@ 2>/dev/null | sed -e 's/^.*\(SATISFIABLE\).*/BLAH/;t;d')
    if [ "$RESULT" != "BLAH" ] ; then
        echo "Error: \"clingo-dl $encoding $instance\" is unsatisfiable"
        return 1
    fi
    return 0
}

#------------------------------------------------------------------
# Check that a problem has a valid solution
#------------------------------------------------------------------

check_solution() {
    local base="$1"
    local instance="$2"
    local encoding="../encodings/${base}_encoding_basic.lp"
    local checker="solution_checker.lp"
    local filter="${base}_encoding_to_plan.lp"
    shift ; shift

#    echo "RUNNING: $CLINGODLFACTS $encoding $instance 2>/dev/null | $CLINGOFACTS $filter - | clingo $instance ${checker} -"

    RESULT1=$($CLINGODLFACTS $encoding $instance $@ 2>/dev/null)
    TMP=$(echo "$RESULT1" | sed -e 's/^.*\(\#false.\).*/BLAH/;t;d')
    if [ "$TMP" == "BLAH" ] ;then
        echo "Failure due to unsat problem: $CLINGODLFACTS $encoding $instance $@"
        return 1
    fi
    RESULT2=$(echo $RESULT1 | $CLINGOFACTS $filter - | clingo user_output.lp ${checker} - )
    TMP=$(echo "$RESULT2" | sed -e 's/^.*\(SATISFIABLE\).*/BLAH/;t;d')
    if [ "$TMP" != "BLAH" ] ; then
        echo "Solution checker failure: $encoding $instance $@"
        echo "$RESULT2"
        return 1
    fi
    return 0
}


#------------------------------------------------------------------
# The Walk DL encoding - unsatisfiable problems
#------------------------------------------------------------------
check_walk_dl(){
    local args10="-c maxstep=10"
    local args20="-c maxstep=20"
    check_unsat $WALK_DL instances/unsat1.lp $args10
    check_unsat $WALK_DL instances/unsat2.lp $args10
    check_unsat $WALK_DL instances/unsat3.lp $args10
    check_unsat $WALK_DL instances/unsat4.lp $args10
    check_unsat $WALK_DL instances/unsat5.lp $args10

    check_solution $WALK_DL instances/sat1.lp $args10
    check_solution $WALK_DL instances/sat2.lp $args10
    check_solution $WALK_DL instances/sat3.lp $args10
    check_solution $WALK_DL instances/sat4.lp $args10
    check_solution $WALK_DL instances/sat5.lp $args10
    check_solution $WALK_DL instances/sat6.lp $args10
    check_solution $WALK_DL instances/sat7.lp $args10
    check_solution $WALK_DL instances/sat8.lp $args10
    check_solution $WALK_DL instances/sat9.lp $args10

    check_solution $WALK_DL instances/walk_sat_pathfast_unsat1.lp $args10
    check_solution $WALK_DL instances/walk_sat_pathfast_unsat2.lp $args10
    check_solution $WALK_DL instances/walkpath_sat_fast_unsat1.lp $args10

    check_solution $WALK_DL instances/instance1.lp $args20


}

#------------------------------------------------------------------
# The Path DL encoding - unsatisfiable problems
#------------------------------------------------------------------

check_path_dl(){

    check_unsat $PATH_DL instances/unsat1.lp
    check_unsat $PATH_DL instances/unsat2.lp
    check_unsat $PATH_DL instances/unsat3.lp
    check_unsat $PATH_DL instances/unsat4.lp
    check_unsat $PATH_DL instances/unsat5.lp
    check_unsat $PATH_DL instances/walk_sat_pathfast_unsat1.lp
    check_unsat $PATH_DL instances/walk_sat_pathfast_unsat2.lp

    check_solution $PATH_DL instances/sat1.lp
    check_solution $PATH_DL instances/sat2.lp
    check_solution $PATH_DL instances/sat3.lp
    check_solution $PATH_DL instances/sat4.lp
    check_solution $PATH_DL instances/sat5.lp
    check_solution $PATH_DL instances/sat6.lp
    check_solution $PATH_DL instances/sat7.lp
    check_solution $PATH_DL instances/sat8.lp
    check_solution $PATH_DL instances/sat9.lp

    check_solution $PATH_DL instances/walkpath_sat_fast_unsat1.lp

    check_solution $PATH_DL instances/instance1.lp
}

#------------------------------------------------------------------
# The Fast-Path DL encoding - unsatisfiable problems
#------------------------------------------------------------------

check_fast_dl(){

    check_unsat $FAST_DL instances/unsat1.lp
    check_unsat $FAST_DL instances/unsat2.lp
    check_unsat $FAST_DL instances/unsat3.lp
    check_unsat $FAST_DL instances/unsat4.lp
    check_unsat $FAST_DL instances/unsat5.lp

    # Problems with added timing restrictions
    check_unsat $FAST_DL instances/walkpath_sat_fast_unsat1.lp

    # Two boundary cases for fast encoding
    check_unsat $FAST_DL instances/fast_unsat_edgeconflict1.lp
    check_unsat $FAST_DL instances/fast_unsat_edgeconflict2.lp

    check_unsat $FAST_DL instances/walk_sat_pathfast_unsat1.lp
    check_unsat $FAST_DL instances/walk_sat_pathfast_unsat2.lp


    check_solution $FAST_DL instances/sat1.lp
    check_solution $FAST_DL instances/sat2.lp
    check_solution $FAST_DL instances/sat3.lp
    check_solution $FAST_DL instances/sat4.lp
    check_solution $FAST_DL instances/sat5.lp
    check_solution $FAST_DL instances/sat6.lp
    check_solution $FAST_DL instances/sat7.lp
    check_solution $FAST_DL instances/sat8.lp
    check_solution $FAST_DL instances/sat9.lp

    check_solution $FAST_DL instances/instance1.lp
}


#------------------------------------------------------------------
# main
#------------------------------------------------------------------

#check_walk_dl
check_path_dl
check_fast_dl

