#!/bin/bash
#script to run group-level analysis
#bash /mnt/j/ANVIL/NettaData/x.Group_bin.sh

DO_Activation=0
DO_Threshold=0
DO_use_afc=0
DO_Cluster=1

#GLM but instead on a group analysis vs. 10 datasets

if [ "${DO_Activation}" -eq 1 ]
then
  echo "******************"
  echo "Group activation"
  echo "******************"

  output_dir="mnt/j/ANVIL/NettaData/BIDS/derivatives/group"
  input_prefix="mnt/j/ANVIL/NettaData/BIDS/derivatives"
  version="vP2_SPC"

  run3dMEMA="3dMEMA -prefix ${output_dir}/3dMEMA_${version}_nonbin_OC_Mm"	#<-- CHANGE
  run3dMEMA="${run3dMEMA}"

  for Force in Nonbin 	#bin		#<-- CHANGE
  do
	  run3dMEMA="${run3dMEMA} -set ${Force}"
	  for subject in sub-01_2 sub-02 sub-03 sub-04 sub-05; do
		  for task in TASK1 TASK2; do
			  # if [[ ${task} == "TASK2" && ${subject} -eq "sub-02" ]]; then
				# echo ${subject}_${task} "Small loop -- ope please disregard this dataset (cuz it shouldn't exist in our analysis)"
				# break 1
			  # fi
			  bcoef="${input_prefix}/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bcoef_${Force}_force_func2stand.nii.gz"
			  tstat="${input_prefix}/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_tstat_${Force}_force_func2stand.nii.gz"
			  run3dMEMA="${run3dMEMA} ${subject} ${bcoef} ${tstat}"
			  echo ${subject}_${task} "This dataset has made it to the important part of the loop -- YAYYYY"
		  done
	  done
  done

  run3dMEMA="${run3dMEMA} -unequal_variance"
  run3dMEMA="${run3dMEMA} -max_zeros 0.25 -model_outliers"
  run3dMEMA="${run3dMEMA} -mask usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz"

  eval ${run3dMEMA}

else
  echo "*****************************"
  echo "Not doing Group activation"
  echo "*****************************"
fi


if [ "${DO_Threshold}" -eq 1 ]
then
  echo "*****************"
  echo "Find threshold values"
  echo "*****************"

  # Only have to run this all once for all group analyses since you are using the same subjects/models

  output_dir="mnt/j/ANVIL/NettaData/BIDS/derivatives/group"
  input_prefix="mnt/j/ANVIL/NettaData/BIDS/derivatives"

  # Cluster results of group analysis
  # Get acf for each individual subject
  for subject in sub-01_2 sub-02 sub-03 sub-04 sub-05; do
	  for task in TASK1 TASK2; do
		  # if [[ ${task} == "TASK2" && ${subject} -eq "sub-02" ]]; then
		  	  # echo ${subject}_${task}
			  # break 1
		  # fi
		  run3dFWHMx="3dFWHMx -input ${input_prefix}/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_errts.nii.gz -acf ${output_dir}/${subject}_${task}_acf_emp.1D"
		  run3dFWHMx="${run3dFWHMx} > ${output_dir}/${subject}_${task}_acf.1D"
		  eval ${run3dFWHMx}
	  done
  done

fi

if [ "${DO_use_afc}" -eq 1 ]
then
  echo "*****************"
  echo "ACF values"
  echo "*****************"

  # Find average acf (4 values)

  # Get cluster information; use average acf values (first 3 numbers)
  3dClustSim -prefix "${output_dir}/3dMEMA_vP2_SPC_bcoef_clustSim_noOrth_Mm" \
    -mask "usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz" \
    -acf 0.3159627 3.580581 8.362137 -iter 5000

else
  echo "***************************"
  echo "Not doing Find threshold values"
  echo "***************************"
fi

#bash /mnt/j/ANVIL/NettaData/x.Group_bin.sh

if [ "${DO_Cluster}" -eq 1 ]
then
  echo "*****************"
  echo "Cluster results"
  echo "*****************"

  #https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dClusterize.html
  output_dir="mnt/j/ANVIL/NettaData/BIDS/derivatives/group"
  input_prefix="mnt/j/ANVIL/NettaData/BIDS/derivatives"

  # lowvhigh, lowvmed, then medvhigh ; 0.005 then 0.001 for p-value. Change -clust_nvox each time
  # Actually threshold and cluster based on info from 3dClustSim
  # Change p value and -clust_nvox based on 3dClustSim results
  # Try out p=0.005 and cluster number corresponding to a=0.05; and p=0.001 and a=0.05
  # Run this for each group analysis												CHANGE LINES 118, 120, 121
  3dClusterize -inset "${output_dir}/3dMEMA_vP2_SPC_Nonbin_OC_Mm+tlrc.BRIK" \
    -mask "usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz" \
    -ithr 1 -idat 0 -bisided p=0.005 -NN 1 -clust_nvox 159 \
    -pref_dat "${output_dir}/Nonbin_bi_clusters_005_05_Mm.nii.gz"

else
  echo "*****************************"
  echo "Not doing Cluster results"
  echo "*****************************"
fi

# ###
# cd /mnt/j/ANVIL/NettaData/BIDS/derivatives/group
# 3dAFNItoNIFTI 3dMEMA_vP2_SPC_bin_OC_Mm+tlrc. -prefix 3dMEMA_vP2_SPC_bin_OC_Mm.nii	#https://stackoverflow.com/questions/32728050/how-to-convert-afni-data-to-nifti-data 
# 3dAFNItoNIFTI 3dMEMA_vP2_SPC_Nonbin_OC_Mm+tlrc. -prefix 3dMEMA_vP2_SPC_Nonbin_OC_Mm.nii		#https://stackoverflow.com/questions/32728050/how-to-convert-afni-data-to-nifti-data 


# How to convert from .nii to .nii.gz <-- use gzip MATLAB

