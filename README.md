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

## Organization and File Structure

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

## Configuration and Usage

## Storage Requirements

