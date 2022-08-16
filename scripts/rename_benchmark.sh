#!/usr/bin/env bash

[ "$_MB_IMPORTED_modules_bootstrap" != "1" ] && source $HOME/local/etc/bash.d/modules_bootstrap.sh
mbset_MODULE_PATH $HOME/.bash.d
mbimport logging
mbimport prompts

#BMARK_SOURCE_NAME="instances-dorabot-coarse"
#BMARK_SOURCE_NAME="instances-dorabot-coarse-maxstep"
#BMARK_SOURCE_NAME="instances-dorabot-detailed"
BMARK_SOURCE_NAME="instances-dorabot-detailed-maxstep"

#BMARK_DST_NAME="instances-dorabot"
#BMARK_DST_NAME="instances-dorabot-large"
#BMARK_DST_NAME="instances-dorabot-maxstep"
BMARK_DST_NAME="instances-dorabot-large-maxstep"

#BMARK_SOURCE_DIR="dorabot_coarse"
#BMARK_SOURCE_DIR="dorabot_coarse_maxstep"
#BMARK_SOURCE_DIR="dorabot_detailed"
BMARK_SOURCE_DIR="dorabot_detailed_maxstep"

#BMARK_DST_DIR="dorabot"
#BMARK_DST_DIR="dorabot_large"
#BMARK_DST_DIR="dorabot_maxstep"
BMARK_DST_DIR="dorabot_large_maxstep"

SOURCE_MAP_PREFIX="map4_20220223"
DST_MAP_PREFIX="map5"

# ----------------------------------------------------------------------------------------
# Rename the input benchmark data file
# ----------------------------------------------------------------------------------------
rename_input_file (){
    local in_path="$1"
    local in_dirname=$(dirname "$in_path")
    local out_dirname=$(echo "${in_dirname}" | sed -e s!$BMARK_SOURCE_DIR!$BMARK_DST_DIR!)
    local in_basename=$(basename "$in_path")
    local out_basename=$(echo "${in_basename}" | sed -e s!$SOURCE_MAP_PREFIX!$DST_MAP_PREFIX!g)
    local out_path="${out_dirname}/${out_basename}"

    if [ "${in_dirname}" != "${out_dirname}" ]; then
        log_info "Creating directory ${out_dirname}"
        mkdir -p "${out_dirname}"
    fi

    log_info "Renaming $in_path to $out_path"
    mv "${in_path}" "${out_path}"
}

# ----------------------------------------------------------------------------------------
# Rename the generated sub-directory for the benchmark input data file
# ----------------------------------------------------------------------------------------
rename_benchmark_dir (){
    local in_path="$1"
    local in_dirname=$(dirname "$in_path")
    local out_dirname=$(echo "${in_dirname}" | sed -e s!$BMARK_SOURCE_NAME!$BMARK_DST_NAME!)
    local in_basename=$(basename "$in_path")
    local out_basename=$(echo "${in_basename}" | sed -e s!$SOURCE_MAP_PREFIX!$DST_MAP_PREFIX!g)
    local out_path="${out_dirname}/${out_basename}"

    if [ "${in_dirname}" != "${out_dirname}" ]; then
        log_info ""
        log_info "Creating directory ${out_dirname}"
        mkdir -p "${out_dirname}"
    fi

    log_info "Renaming $in_path to $out_path"
    mv "${in_path}" "${out_path}"
}

# ----------------------------------------------------------------------------------------
# Rename the generated sub-directory for the benchmark input data file
# ----------------------------------------------------------------------------------------
modify_start_file (){
    local in_file="$1"
    local search="${BMARK_SOURCE_DIR}/${SOURCE_MAP_PREFIX}"
    local replace="${BMARK_DST_DIR}/${DST_MAP_PREFIX}"

    echo "Replacing ${search} with ${replace} in ${in_file}"
    sed -i.backup s!${search}!${replace}! "$in_file"
}

# ----------------------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------------------

# Need to rename file for the input instance data file
rename_input_files(){
    local search="*/instances/${BMARK_SOURCE_DIR}/${SOURCE_MAP_PREFIX}*"
    declare -a INPUT_FILES=($(find . -wholename "${search}"))
    for fn in "${INPUT_FILES[@]}"; do
        rename_input_file "$fn"
    done
}

# Need to rename the generated benchmark dir and modify the start.sh file for
# the renamed input source data file
update_generated_data(){
    local search="*/juggling-results/*${BMARK_SOURCE_NAME}/*/${SOURCE_MAP_PREFIX}*"
    declare -a INPUT_FILES=($(find . -type d -links 3 -wholename "${search}"))
    for fn in "${INPUT_FILES[@]}"; do
        modify_start_file "$fn/run1/start.sh"
        rename_benchmark_dir "$fn"
    done
}

fix_update_generated_data(){
    local search="*/juggling-results/*${BMARK_DST_NAME}/*/${DST_MAP_PREFIX}*"
    declare -a INPUT_FILES=($(find . -type d -links 3 -wholename "${search}"))
    for fn in "${INPUT_FILES[@]}"; do
        modify_start_file "$fn/run1/start.sh"
    done
}


# ----------------------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------------------

go(){
    rename_input_files
    update_generated_data
#    special_update_generated_data
}

SOURCE_FILE_PATTERN="instances/${BMARK_SOURCE_DIR}/${SOURCE_MAP_PREFIX}<suffix>"
DST_FILE_PATTERN="instances/${BMARK_DST_DIR}/${DST_MAP_PREFIX}<suffix>"
SOURCE_DATA_PATTERN="juggling-results/*/${BMARK_SOURCE_NAME}/*/${SOURCE_MAP_PREFIX}<suffix>"
DST_DATA_PATTERN="juggling-results/*/${BMARK_DST_NAME}/*/${DST_MAP_PREFIX}<suffix>"

log_warn "Changing benchmark instance file:"
log_warn "    from: ${SOURCE_FILE_PATTERN}"
log_warn "      to: ${DST_FILE_PATTERN}"
log_warn "Changing benchmark generated data:"
log_warn "    from: ${SOURCE_DATA_PATTERN}"
log_warn "      to: ${DST_DATA_PATTERN}"

GO=$(prompt_yesno "Are you sure you want to proceed [y/N]" "n")
if [ "$GO" == "y" ]; then
    go
    log_info "Done"
else
    log_info "Aborting..."
fi


