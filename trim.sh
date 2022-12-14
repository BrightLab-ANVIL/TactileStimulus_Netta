#!/bin/bash
# bash /mnt/j/ANVIL/NettaData/trim.sh

parent_dir2="mnt/j/ANVIL/NettaData"
subject="sub-05"	#sub-04 	sub-05
task="TASK2"	#TASK2


fslroi mnt/j/ANVIL/NettaData/BIDS/derivatives/${subject}/func/${task}/output.SPC/${subject}_${task}_SPC_smo.nii.gz mnt/j/ANVIL/NettaData/BIDS/derivatives/${subject}/func/${task}/output.SPC/${subject}_${task}_SPC_smo_trimmed.nii.gz 10 295
# tail -n +11 <mnt/j/ANVIL/NettaData/BIDS/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_1_mc_demean.1D >mnt/j/ANVIL/NettaData/BIDS/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_1_mc_demean_trimmed.1D
# tail -n +11 <mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_bin_HRFconv_1dcat.1D >mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_bin_HRFconv_1dcat_trimmed.1D
# # THIS ONE DOESN'T WORK --> tail -n +11 <mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_ort_HRFconv_1dcat.1D >mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_ort_HRFconv_1dcat_trimmed.1D
# #How about this: trim the non-ort'ed Nonbinary 1D file
# tail -n +11 <mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_HRFconv_1dcat.1D >mnt/j/ANVIL/NettaData/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_HRFconv_1dcat_trimmed.1D
# #Then orthoganalize the trimmed Nonbinary 1D file using the ort.sh file...


#############################################