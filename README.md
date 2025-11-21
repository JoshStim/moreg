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

## Configuration and Usage

## Storage Requirements
<<<<<<< HEAD
=======

>>>>>>> 42842cd (Renamed step1_run_steup_moreg to step1_run_setup_moreg)
