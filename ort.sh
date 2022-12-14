#!/bin/bash
# bash ort.sh
# bash /mnt/j/ANVIL/NettaData/ort.sh

# #THIS WORKED!!!!!	########################################################################
#Now apply to: mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_HRFconv_1dcat_trimmed.1D

cd /
cd mnt/j/ANVIL/NettaData/task_regressors/sub-02/TASK2/
3dTproject -ort sub-02_TASK2_Force_bin_HRFconv_1dcat_trimmed.1D -prefix "sub-02_TASK2_Force_Nonbin_HRFconv_1dcat_trimmed_ort" -input 'sub-02_TASK2_Force_Nonbin_HRFconv_1dcat_trimmed.1D'\'

#Below had worked for the 1dcat commands...

#directory = "mnt/j/ANVIL/NettaData/task_regressors"

# for subject in sub-04 sub-05
# do
	# for task in TASK1 TASK2
	# do

		# #1dcat mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_bin_HRFconv.1D > mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_bin_HRFconv_1dcat.1D 
		# #1dcat mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_HRFconv.1D > mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_HRFconv_1dcat.1D

		# 3dTproject -ort mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_bin_HRFconv_1dcat.1D -prefix "${subject}_${task}_Force_Nonbin_ort_HRFconv_1dcat.1D" -input 'mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_HRFconv_1dcat.1D'\'
		
	# done
# done

