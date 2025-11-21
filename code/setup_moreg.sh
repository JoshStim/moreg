#!/bin/bash
#SBATCH --job-name=prep_moreg
#SBATCH --ntasks=1
#SBATCH --time=20:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/prep.log

set -eu

readonly TASKS=(EMOTION GAMBLING LANGUAGE MOTOR RELATIONAL SOCIAL WM)
readonly METHODS=(fd_mag_convolved fd_mag_convolved_w_motion_params motion_params_only no_motion_correction)
readonly PEDS=(LR RL)

module load matlab

# add or update parameter in fsf file
modify_fsf() {
    if [[ "$#" -ne 3 ]]; then
        echo "Usage: modify_fsf <command_name> <command_value> <fsf_file>"
        return 1
    fi

    local command_name=$1
    local command_value=$2
    local fsf_file=$3

    if grep -q "^$command_name " "${fsf_file}"; then
        echo "Updating existing parameter: $command_name"
        sed -i "s|^$command_name .*|$command_name $command_value|" "${fsf_file}"
        echo "fsf file updated successfully!"
    else
        echo "FSL command does not exist in ${fsf_file}!"
    fi
}

insert_line_after() {
    if [[ "$#" -ne 3 ]]; then
        echo "Usage: insert_line_after <keyword> <new_line> <file>"
        return 1
    fi

    local keyword=$1
    local new_line=$2
    local file=$3

    sed -i "/${keyword}/a ${new_line}" "${file}"
}

make_motion_regressor_table_batch() {

    if [[ "$#" -ne 3 ]]; then
        echo "Usage: make_motion_regressor_table_batch <motion_regressor_paths> <method> <outp>"
        return 1
    fi

    local -r motion_regressor_paths=$1
    local -r method=$2
    local -r outp=$3

    matlab -nodisplay -nosplash -nodesktop -r \
        "addpath('${MOREG_ROOT}/code/make_motion_regressor_table'); make_regressor_table_batch('$motion_regressor_paths', '$method', '$outp'); exit;"

}

setup_moreg() {

    ### Check for correct number of inputs ###
    if [[ "$#" -ne 4 ]]; then
        echo "Usage: setup <task> <ped> <method> <output>"
        return 1
    fi

    local -r task=$1
    local -r ped=$2
    local -r method=$3
    local -r outd=$4

    ### STEP 1: initialize output directory ###
    local -r outp="${outd}/${task}_${ped}_${method}"
    mkdir -p "${outp}"

    ### STEP 2: set up environment variables ###
    local -r motion_regressor_paths="${outp}/motion_regressor_files.txt"
    local -r fsf_template="${MOREG_ROOT}/feat_templates/${method}/tfMRI_${task}_hp200_s4_level1.fsf"
    local -r fsf_working_file="tfMRI_${task}_${ped}_hp200_s4_level1_${method}.fsf"
    local -r fsf_working="${outp}/${fsf_working_file}"
    local -r fsf_files="${outp}/fsf_files.txt"

    # STEP 3: prepare inputs that will be required for feat
    motion_regressor_paths_arr=()
    hcp_subject_paths_arr=()
    #for sub in "${HCP_ROOT}"/??????; do
        sub="${HCP_ROOT}"/100408
        tfmri="${sub}"/MNINonLinear/Results/tfMRI_"${task}"_"${ped}"
        nii="${tfmri}"/tfMRI_"${task}"_"${ped}".nii.gz
        evs="${tfmri}"/EVs
        regressors="${tfmri}"/Movement_Regressors_dt.txt

        if [[ (! -f $nii) || (! -d $evs) || (! -f $regressors) ]]; then
            printf "%s missing inputs. skipping\n" "${sub}"
            continue
        fi
        subid=$(basename "${sub}")
        out_sub_dir=${outp}/"${subid}"
        mkdir -p "${out_sub_dir}"
        hcp_subject_paths_arr+=("${out_sub_dir}")

        cp -sa "${evs}" "${out_sub_dir}"/
        cp -sva "${nii}" "${out_sub_dir}"/

        if [[ "${method}" != "no_motion_correction" ]]; then
            motion_regressor_dst="${out_sub_dir}"/Movement_Regressors_dt.txt
            cp -sa "${regressors}" "${motion_regressor_dst}"
            motion_regressor_paths_arr+=("${motion_regressor_dst}")
        fi
    #done
    # remove old copies of fd files from existing runs
    find "${outp}" -type l -name "fd_*" -delete

    ### STEP 4: make confound tables ###
    if [[ "${method}" != "no_motion_correction" ]]; then
        printf "%s\n" "${motion_regressor_paths_arr[@]}" >"${motion_regressor_paths}"
        make_motion_regressor_table_batch "${motion_regressor_paths}" "${method}" "${outp}"
    fi

    ### STEP 5: modify and export fsf file from template ###
    cp "${fsf_template}" "${fsf_working}"

    ### STEP 6: write out list of fsfs to process
    fsfs=()
    for hcp_subject_path in "${hcp_subject_paths_arr[@]}"; do
        fsf="${hcp_subject_path}"/"${fsf_working_file}"
        cp -a "${fsf_working}" "${fsf}"

        modify_fsf \
            "set fmri(outputdir)" \
            "tfMRI_${task}_${ped}_hp200_s4" \
            "${fsf}"

        modify_fsf \
            "set feat_files(1)" \
            "\"${hcp_subject_path}/tfMRI_${task}_${ped}.nii.gz\"" \
            "${fsf}"

        # define confound evs filepath
        if [[ "${method}" == "fd_mag_convolved" || "${method}" == "fd_mag_convolved_w_motion_params" ]]; then
            cut -d " " -f 1 "${hcp_subject_path}/EVs/${method}.txt" | awk 'NR > 1' > "${hcp_subject_path}/EVs/fd_convolved_no_dx.txt"
            cut -d " " -f 2- "${hcp_subject_path}/EVs/${method}.txt" > "${hcp_subject_path}/EVs/confound_evs.txt"
            rm "${hcp_subject_path}/EVs/${method}.txt"
        elif [[ "${method}" == "motion_params_only" ]]; then
            mv "${hcp_subject_path}/EVs/${method}.txt" "${hcp_subject_path}/EVs/confound_evs.txt"
        fi

        fsfs+=("${fsf}")

    done
    printf "%s\n" "${fsfs[@]}" >"${fsf_files}"

}

main() {

    local -r outd=$OUTPUT

    # generate fsfs for each combination of parameters
    for task in "${TASKS[@]}"; do
        for ped in "${PEDS[@]}"; do
            for method in "${METHODS[@]}"; do
                setup_moreg "${task}" "${ped}" "${method}" "${outd}"
            done
        done
    done

    # gather all of these fsfs into a single file
    local -r all_fsfs=${outd}/all_fsfs
    if [[ -f $all_fsfs ]]; then
        rm "${all_fsfs}"
    fi
    touch "${all_fsfs}"
    mapfile -t fsf_files < <(find "${outd}" -maxdepth 2 -name fsf_files.txt)
    for fsf in "${fsf_files[@]}"; do
        cat "${fsf}" >>"${all_fsfs}"
    done
}

export -f setup_moreg \
    main \
    insert_line_after \
    modify_fsf \
    make_motion_regressor_table_batch

main
