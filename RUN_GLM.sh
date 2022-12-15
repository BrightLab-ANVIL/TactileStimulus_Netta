#!/bin/bash
# bash /mnt/j/ANVIL/NettaData/RUN_GLM.sh

#version?
parent_dir2="mnt/j/ANVIL/NettaData"

for subject in sub-01_2 sub-02 sub-03 sub-04 sub-05; do
	for task in TASK1 TASK2; do
		# if [[ ${task} == "TASK2" && ${subject} -eq "sub-02" ]]; then
			# echo ${subject}_${task}
			# break 1
		# fi

		input_file=${parent_dir2}/BIDS/derivatives/${subject}/func/${task}/output.SPC/${subject}_${task}_SPC_smo_trimmed.nii.gz
		motion_file=${parent_dir2}/BIDS/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_1_mc_demean_trimmed.1D
		Binforce_file=${parent_dir2}/task_regressors/${subject}/${task}/${subject}_${task}_Force_bin_HRFconv_1dcat_trimmed.1D
		Nonbinforce_file=${parent_dir2}/task_regressors/${subject}/${task}/${subject}_${task}_Force_Nonbin_HRFconv_1dcat_trimmed_ort.1D
		sub_ID=${subject}_${task}
		output_dir=${parent_dir2}/BIDS/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo

		${parent_dir2}/x.GLM_REML.sh ${input_file} ${motion_file} ${Binforce_file} ${Nonbinforce_file} ${sub_ID} ${output_dir}

    done
done

