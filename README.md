# TactileStimulus_Netta

This repo includes all of the scripts that I ultimately used in processing the fMRI data for the tactile stimulus paper in collaboration with the Netta Gurari lab. The preprocessing step specifically requires scripts that can be found in this repo: https://github.com/BrightLab-ANVIL/PreProc_BRAIN

Processing Steps Completed:
1. Preprocess the fMRI files (x.PreProc_RUN_Netta.sh)
	a. Instructions for each of the preprocessing steps can be found in the PreProc_BRAIN repo README. Additionally, more information for each function can be found in the detailed function scripts themselves.
2. Make task paradigms for each of the datasets (hrf_conv_edit_bin_nonbin.m)
3. Match task paradigm lengths to scan length (trim_regressors.m)
	a. Use 3dinfo -nv to determine the scan length of the BOLD fMRI file.
4. Trim the first 10 volumes of the regressors and input scan (trim.sh)
5. Orthogonalize each of the *trimmed* nonbinary task paradigms (ort.sh)
6. Run GLM for each of the datasets (RUN_GLM.sh)
7. Transform each of the datasets (x.PreProc_RUN_Netta.sh)
	a. Use AFNI function 3dbucket to extract beta coefficients and t stats for each of the force levels
	b. Using Transform_nonlin, apply func2stand matrix to beta map and t stat map
8. Perform group analysis on the standard space maps – incorporate all 10 datasets (x.Group_bin.sh)

