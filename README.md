# moreg
## Overview
The purpose of the moreg pipeline is to run Level 1 FEAT analyses and perform different variations of motion regression on each scan of the HCP 1200 dataset, which contains task-based fMRI data for 1200 adult participants.

Prior to running the pipeline, the user may choose one or more of the 4 motion regression options to implement:

1) Include 12 motion regressors as confound events in the level 1 design matrix

2) Include HRF-convolved thresholded FD trace as a task event, and its first/second derivatives as confounds in the level 1 design matrix

3) Include HRF-convolved thresholded FD trace as a task event, and its first/second derivatives AND 12 motion regressors as confounds in the level 1 design matrix

4) Do not include any motion regressors in the level 1 design matrix.

For each scan in the dataset, the pipeline creates an .fsf file for each option (`step1_setup_moreg`) and implements the corresponding motion regression techniques through separate level 1 FEAT analyses (`step2_do_feat`).

## Requirements
This pipeline requires local or remote access to the HCP1200 dataset and the Joint HPC Exchange (JHPCE) for submitting batch jobs and loading modules.

## File Organization and Description

```
.
├── README.md
├── code
│   ├── do_feat
│   ├── make_motion_regressor_table
│   │   ├── convolve_fd.m
│   │   ├── extract_taskname.m
│   │   ├── get_fd.m
│   │   ├── make_regressor_table.m
│   │   └── make_regressor_table_batch.m
│   └── setup_moreg.sh
├── feat_templates
│   ├── fd_mag_convolved
│   │   ├── tfMRI_EMOTION_hp200_s4_level1.fsf
│   │   ├── tfMRI_GAMBLING_hp200_s4_level1.fsf
│   │   ├── tfMRI_LANGUAGE_hp200_s4_level1.fsf
│   │   ├── tfMRI_MOTOR_hp200_s4_level1.fsf
│   │   ├── tfMRI_RELATIONAL_hp200_s4_level1.fsf
│   │   ├── tfMRI_SOCIAL_hp200_s4_level1.fsf
│   │   └── tfMRI_WM_hp200_s4_level1.fsf
│   ├── fd_mag_convolved_w_motion_params
│   │   ├── tfMRI_EMOTION_hp200_s4_level1.fsf
│   │   ├── tfMRI_GAMBLING_hp200_s4_level1.fsf
│   │   ├── tfMRI_LANGUAGE_hp200_s4_level1.fsf
│   │   ├── tfMRI_MOTOR_hp200_s4_level1.fsf
│   │   ├── tfMRI_RELATIONAL_hp200_s4_level1.fsf
│   │   ├── tfMRI_SOCIAL_hp200_s4_level1.fsf
│   │   └── tfMRI_WM_hp200_s4_level1.fsf
│   ├── motion_params_only
│   │   ├── tfMRI_EMOTION_hp200_s4_level1.fsf
│   │   ├── tfMRI_GAMBLING_hp200_s4_level1.fsf
│   │   ├── tfMRI_LANGUAGE_hp200_s4_level1.fsf
│   │   ├── tfMRI_MOTOR_hp200_s4_level1.fsf
│   │   ├── tfMRI_RELATIONAL_hp200_s4_level1.fsf
│   │   ├── tfMRI_SOCIAL_hp200_s4_level1.fsf
│   │   └── tfMRI_WM_hp200_s4_level1.fsf
│   └── no_motion_correction
│       ├── tfMRI_EMOTION_hp200_s4_level1.fsf
│       ├── tfMRI_GAMBLING_hp200_s4_level1.fsf
│       ├── tfMRI_LANGUAGE_hp200_s4_level1.fsf
│       ├── tfMRI_MOTOR_hp200_s4_level1.fsf
│       ├── tfMRI_RELATIONAL_hp200_s4_level1.fsf
│       ├── tfMRI_SOCIAL_hp200_s4_level1.fsf
│       └── tfMRI_WM_hp200_s4_level1.fsf
├── hrf_models
│   ├── hrf_model.mat
│   ├── hrf_model_dx1.mat
│   └── hrf_model_dx2.mat
├── step1_run_setup_moreg
└── step2_run_do_feat
```

  * `./code/do_feat`: JHPCE batch script. Submits array job for running level 1 FEAT analyses given selected .fsf files. Requires user to input 1) a .txt file containing .fsf paths, and 2) the size of the array (i.e., number of .fsf files to execute).

  * `./code/make_motion_regressor_table`: Contains MATLAB functions for extracting motion regressors, calculating framewise displacements (FD), and convolving FD traces with the modeled HRF.

  * `./code/setup_moreg.sh`: JHPCE batch script. Submits a job that consolidates all of the HCP data needed to run level 1 FEAT analyses and motion correction methods on each HCP scan. Also constructs a .fsf file for each scan and motion correction method.

  * `./feat_templates`: Contains template .fsf files for each task and motion correction method. These templates are used to construct scan-specific .fsf files in `setup_moreg.sh`.

  * `./hrf_models`: Contains the HRF model, along with its first and second derivatives, used for convolving thresholded FD traces.

  * `./step1_run_setup_moreg`: A shell script that initiates `setup_moreg.sh` based on user-defined inputs.

  * `./step2_run_do_feat`: A shell script that initiates `do_feat` based on user-defined inputs.

## Configuration and Usage
This pipeline contains two steps: `step1_run_setup_moreg` and `step2_run_do_feat`.

Before running `step1_run_setup_moreg`, the user must modify some parameters at the beginning of the script. These parameters are shown below:
```
export MOREG_ROOT=/path/to/moreg # path to moreg folder
export HCP_ROOT=/path/to/hcp     # path to HCP1200 folder containing all participant data
export OUTPUT=/path/to/output    # path to output folder
```

When `step1_run_setup_moreg` is finished running, the user may run `step2_run_do_feat`. This also requires the user to modify some parameters at the beginning of the script. These are shown below:
```
export OUTPUT=/path/to/output                     # path to output folder (same as in step1_run_setup_moreg)                                   
export TASKS=(EMOTION \
              GAMBLING \
              LANGUAGE \
              MOTOR \
              RELATIONAL \
              SOCIAL \
              WM)                                 # list of tasks to run FEAT analysis on
export METHODS=(no_motion_correction \
                motion_params_only \
                fd_mag_convolved \
                fd_mag_convolved_w_motion_params) # list of motion correction 
```

## Storage Requirements

