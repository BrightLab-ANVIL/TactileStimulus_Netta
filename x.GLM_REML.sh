#!/bin/bash
#This script uses pre-processed brain fMRI data and and creates a general linear model using AFNI.

#Check if the inputs are correct
if [ $# -ne 6 ]
then
  echo "Insufficient inputs"
  echo "Input 1 should be the fMRI data you want to model"
  echo "Input 2 should be the demeaned motion parameters"
  echo "Input 3 should be the binary force regressor"
  echo "Input 4 should be the nonbinary force regressor"
  echo "Input 5 should be the subject ID"
  echo "Input 6 should be the output directory"
  exit
fi

input_file="${1}"
motion_file="${2}"
Binforce_file="${3}"
Nonbinforce_file="${4}"
sub_ID="${5}"
output_dir=${6}

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi

if [ ! -f ${output_dir}/"${sub_ID}_bucket.nii.gz" ]
then

  # Create design matrix using 3dDeconvolve
  3dDeconvolve -input ${input_file} -polort 3 -num_stimts 8 \
  -stim_file 1 "${motion_file}[0]" -stim_label 1 MotionRx \
  -stim_file 2 "${motion_file}[1]" -stim_label 2 MotionRy \
  -stim_file 3 "${motion_file}[2]" -stim_label 3 MotionRz \
  -stim_file 4 "${motion_file}[3]" -stim_label 4 MotionTx \
  -stim_file 5 "${motion_file}[4]" -stim_label 5 MotionTy \
  -stim_file 6 "${motion_file}[5]" -stim_label 6 MotionTz \
  -stim_file 7 "${Binforce_file}" -stim_label 7 Binforce \
  -stim_file 8 "${Nonbinforce_file}" -stim_label 8 Nonbinforce \
  -x1D ${output_dir}/"${sub_ID}_matrix.1D" -x1D_stop

  # Run GLM using 3dREMLfit
  3dREMLfit -input ${input_file} \
    -matrix ${output_dir}/"${sub_ID}_matrix.1D" \
    -tout -rout \
    -Rbeta ${output_dir}/"${sub_ID}_bcoef.nii.gz" \
    -Rbuck ${output_dir}/"${sub_ID}_bucket.nii.gz" \
    -Rfitts ${output_dir}/"${sub_ID}_fitts.nii.gz" \
    -Rerrts ${output_dir}/"${sub_ID}_errts.nii.gz"

else
  echo "** ALREADY RUN: subject=${sub_ID} **"
fi
