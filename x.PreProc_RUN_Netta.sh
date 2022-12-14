#!/bin/sh
# sh x.PreProc_RUN_Netta.sh
# bash /mnt/j/ANVIL/NettaData/x.PreProc_RUN_Netta.sh


#######################################
# Choose analysis options below (1=run)
#######################################
DO_dcm2niix=0	# this step was performed by Neha already for sub-01_2, sub-04, and sub-05.
DO_fsl_anat=0
DO_thresh_bin=0
#task loop start
DO_PreProc_VolReg_4D_ME=0
DO_PreProc_BET_4D=0
DO_PreProc_Mask_4D=0
DO_tedana=0
DO_smoothing=0
DO_SPC=0

DO_PreProc_TissueReg_func2anat=0	#(register functional and anatomical datasets) <-- NEED TO RUN THIS PRIOR TO RUNNING THE FUNC2STAND ONE
DO_PreProc_TissueReg_func2stand=0	#(register functional/anatomical and standard datasets) <-- THE IMPORTANT ONE

DO_PreProc_Transform_lin=0			#(linear transformation of functional <-> anatomical space)
DO_3dbucket=0
DO_PreProc_Transform_nonlin=0		#(nonlinear transformation of functional <-> standard space)
DO_PreProc_MEANTS=0					#(output a mean time-series from the functional dataset, masked by a tissue mask)

home_dir="mnt/j/ANVIL/NettaData"
parent_dir="mnt/j/ANVIL/NettaData/BIDS"
parent_dir2="mnt/j/ANVIL/NettaData"

#DON'T USE: github_dir="mnt/c/Users/Joshua/Documents/GitHub/PreProc_BRAIN/EOL_converted" <-- spent 2 hours debugging only to realize I was using the wrong directly smh :( 
#DICOM_dir="mnt/j/ANVIL/NettaData/DICOM"	<-- I don't believe I have the DICOM files.

################################
################################
################################

for subject in sub-01_2 sub-02 sub-03 sub-04 sub-05
do

echo "*********************"
echo "Processing ${subject}"
echo "*********************"

########################
###### DICOMtoNIFTI ########
########################

if [ "${DO_dcm2niix}" -eq 1 ]

then
  echo "****************"
  echo "Running dcm2niix"
  echo "****************"

  # anatomical
  dcm2niix_afni -f %f -z y -o ${parent_dir}/sourcedata/${subject}/anat ${DICOM_dir}/${subject}/${subject}_T1w

  # functional
  dcm2niix_afni -f %f_%e -z y -o ${parent_dir}/sourcedata/${subject}/func/TASK1 ${DICOM_dir}/${subject}/${subject}_TASK1
  dcm2niix_afni -f %f_%e -z y -o ${parent_dir}/sourcedata/${subject}/func/TASK1 ${DICOM_dir}/${subject}/${subject}_TASK1_SBREF
  dcm2niix_afni -f %f_%e -z y -o ${parent_dir}/sourcedata/${subject}/func/TASK2 ${DICOM_dir}/${subject}/${subject}_TASK2
  dcm2niix_afni -f %f_%e -z y -o ${parent_dir}/sourcedata/${subject}/func/TASK2 ${DICOM_dir}/${subject}/${subject}_TASK2_SBREF

else
  echo "********************"
  echo "Not running dcm2niix"
  echo "********************"
fi

########################
###### fsl_anat ########
########################

if [ "${DO_fsl_anat}" -eq 1 ]

then
  echo "****************"
  echo "Running fsl_anat"
  echo "****************"

  fsl_anat -i ${parent_dir}/sourcedata/${subject}/anat/${subject}_T1w.nii.gz -o ${parent_dir}/derivatives/${subject}/${subject}_T1w.anat
  # Running it like this uses all the defaults - if you don't use many of the outputs it generates, consider changing the defaults
  # An alternative to fsl_anat: if you only want brain extraction and tissue segmentation on the T1w file - see x.PreProc_BET-anat and x.PreProc_SEG-anat

else
  echo "********************"
  echo "Not running fsl_anat"
  echo "********************"
fi

# sh x.PreProc_RUN_Netta.sh
# bash /mnt/j/ANVIL/NettaData/x.PreProc_RUN_Netta.sh
# ./x.PreProc_BET-anat ${parent_dir}/sourcedata/${subject}/anat/${subject}_T1w.nii.gz ${parent_dir}/derivatives/${subject}/anat
# parent_dir="mnt/j/ANVIL/NettaData/BIDS"

########################
###### thresh_bin ########
########################

if [ "${DO_thresh_bin}" -eq 1 ]

then
  echo "****************"
  echo "Running thresh_bin"
  echo "****************"

  # Threshold and binarize the partial volume image of the tissue class of interest
  fslmaths ${parent_dir}/derivatives/${subject}/anat/T1_fast_pve_1.nii.gz -thr 0.5 -bin ${parent_dir}/derivatives/${subject}/anat/GM_mask_p5.nii.gz
  # e.g. fslmaths output.anat/T1_fast_pve_1.nii.gz -thr 0.5 -bin output.anat/GM_mask_p5.nii.gz (or use AFNI's 3dcalc)
  # You'll need this for x.PreProc_Transform and x.PreProc_MEANTS

else
  echo "********************"
  echo "Not running thresh_bin"
  echo "********************"
fi


########### START TASK LOOP ######################################
for task in TASK1 TASK2
do

echo "*********************"
echo "Processing ${task}"
echo "*********************"


######################################
###### x.PreProc_VolReg_4D_ME ########
######################################

if [ "${DO_PreProc_VolReg_4D_ME}" -eq 1 ]

then
  echo "****************************"
  echo "Running x.PreProc_VolReg-4D_ME"
  echo "****************************"

  # not running rm10 before this
  ${home_dir}/x.PreProc_VolReg-4D_ME.sh "${parent_dir}/sourcedata/${subject}/func/${task}" "${subject}_${task}" 5 "${parent_dir}/sourcedata/${subject}/func/${task}/${subject}_${task}_SBREF_1" 0 ${parent_dir}/derivatives/${subject}/func/${task}/output.mc 1

else
  echo "*******************************"
  echo "Not running x.PreProc_VolReg-4D_ME"
  echo "*******************************"
fi

###################################
########## x.PreProc_BET-4D ##########
###################################

if [ "${DO_PreProc_BET_4D}" -eq 1 ]

then
  echo "****************************"
  echo "Running x.PreProc_BET-4D"
  echo "****************************"

  # for multi-echo
  ${home_dir}/x.PreProc_BET-4D "${parent_dir}/sourcedata/${subject}/func/${task}/${subject}_${task}_SBREF_1" "${parent_dir}/derivatives/${subject}/func/${task}/output.bet"

else
  echo "*******************************"
  echo "Not running x.PreProc_BET-4D"
  echo "*******************************"
fi


###################################
########## x.PreProc_Mask-4D ##########
###################################

if [ "${DO_PreProc_Mask_4D}" -eq 1 ]

then
  echo "****************************"
  echo "Running x.PreProc_Mask-4D"
  echo "****************************"

  # for multi-echo
  for echonum in $(eval echo "{1..5}")
  do
    ${home_dir}/x.PreProc_Mask-4D "${parent_dir}/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_${echonum}_mc" "${parent_dir}/derivatives/${subject}/func/${task}/output.bet/${subject}_${task}_SBREF_1_bet_mask_ero" "${parent_dir}/derivatives/${subject}/func/${task}/output.betmask"
  done

else
  echo "*******************************"
  echo "Not running x.PreProc_Mask-4D"
  echo "*******************************"
fi


###################################
###### tedana ########
###################################

if [ "${DO_tedana}" -eq 1 ]

then
  echo "****************************"
  echo "Running tedana"
  echo "****************************"

  #If output directory is not present, make it
  if [ ! -d ${parent_dir}/derivatives/${subject}/func/${task}/output.tedana ]
  then
    mkdir ${parent_dir}/derivatives/${subject}/func/${task}/output.tedana
  fi

  tedana -d "${parent_dir}/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_1_mc.nii.gz" \
    "${parent_dir}/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_2_mc.nii.gz" \
    "${parent_dir}/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_3_mc.nii.gz" \
    "${parent_dir}/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_4_mc.nii.gz" \
    "${parent_dir}/derivatives/${subject}/func/${task}/output.mc/${subject}_${task}_5_mc.nii.gz" \
    -e 10.6 27.83 45.06 62.29 79.52 \
    --out-dir "${parent_dir}/derivatives/${subject}/func/${task}/output.tedana"

else
  echo "*******************************"
  echo "Not running tedana"
  echo "*******************************"
fi

###################################
###### Smoothing ########
###################################

if [ "${DO_smoothing}" -eq 1 ]

then
  echo "****************************"
  echo "Running Smoothing"
  echo "****************************"

  #If output directory is not present, make it
  if [ ! -d ${parent_dir}/derivatives/${subject}/func/${task}/output.smooth ]
  then
    mkdir ${parent_dir}/derivatives/${subject}/func/${task}/output.smooth
  fi

  3dmerge -1blur_fwhm 5.0 -doall -prefix "${parent_dir}/derivatives/${subject}/func/${task}/output.smooth/desc-optcom_bold_smo.nii.gz" "${parent_dir}/derivatives/${subject}/func/${task}/output.tedana/desc-optcom_bold.nii.gz"

else
  echo "*******************************"
  echo "Not running smoothing"
  echo "*******************************"
fi


###################################
################ SPC ##############
###################################

# bash /mnt/j/ANVIL/NettaData/x.PreProc_RUN_Netta.sh

if [ "${DO_SPC}" -eq 1 ]

then
  echo "****************************"
  echo "Running SPC"
  echo "****************************"

  ## Change BOLD map into units of signal percentage change
  tmp="${parent_dir}/derivatives/${subject}/func/${task}/output.SPC"
  func_in="${parent_dir}/derivatives/${subject}/func/${task}/output.smooth/desc-optcom_bold_smo.nii.gz"

  if [ ! -d ${tmp} ]
  then
    mkdir ${tmp}
  fi

  # Adapted from Stefano code
  echo "Computing SPC of ${func_in} ( [X-avg(X)]/avg(X) )"

  fslmaths ${func_in} -Tmean ${tmp}/${subject}_${task}_mean_smo
  fslmaths ${func_in} -sub ${tmp}/${subject}_${task}_mean_smo -div ${tmp}/${subject}_${task}_mean_smo ${tmp}/${subject}_${task}_SPC_smo

else
  echo "*******************************"
  echo "Not running SPC"
  echo "*******************************"
fi

# ###################################
# ########## x.PreProc_TissueReg ##########
# ###################################

# if [ "${DO_PreProc_TissueReg}" -eq 1 ]

# then
  # echo "****************************"
  # echo "Running x.PreProc_TissueReg"
  # echo "****************************"

  # ${home_dir}/x.PreProc_TissueReg "${parent_dir}/derivatives/${subject}/func/${task}/output.bet/${subject}_${task}_SBREF_1_bet_ero" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg" ${subject}_${task}

# else
  # echo "*******************************"
  # echo "Not running x.PreProc_TissueReg"
  # echo "*******************************"
# fi

#########################################################################
###################### x.PreProc_TissueReg_func2anat ####################
#########################################################################

if [ "${DO_PreProc_TissueReg_func2anat}" -eq 1 ]

then
  echo "****************************"
  echo "Running x.PreProc_TissueReg_func2anat"
  echo "****************************"

  ${home_dir}/x.PreProc_TissueReg_func2anat.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.bet/${subject}_${task}_SBREF_1_bet_ero" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg" ${subject}_${task}

else
  echo "*******************************"
  echo "Not running x.PreProc_TissueReg_func2anat"
  echo "*******************************"
fi

###################################
########## x.PreProc_TissueReg_func2stand ##########
###################################

#Transform beta and t stat maps for high, medium, and low force levels.
#The GLM output files are in the func folder, however, there are only 1 volume
#Regardless of the number of volumes, the maps are still in functional space. Want to register from functional to standard space!
#Thus, this is the only one I'm using from the files Neha shared with me via Slack, I think?
#Input file: mnt/j/ANVIL/NettaData/BIDS/derivatives/sub-04/func/TASK1/output.GLM_REML_OC/sub-04_TASK1_bucket.nii.gz

# input_file_func2anat=${1} --> "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat"
# input_file_anat_brain=${2} --> "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain"
# input_file_anat=${3} --> "${parent_dir}/derivatives/${subject}/anat/T1_biascorr"
# input_file_stand_brain=${4} --> "usr/local/fsl/data/standard/MNI152_T1_2mm_brain" <-- this was from the files that FSLeyes uses.
# input_file_stand=${5} --> "usr/local/fsl/data/standard/MNI152_T1_2mm" <-- this was from the files that FSLeyes uses
# input_file_stand_mask=${6} --> "usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask_dil"
# output_dir=${7} --> "${parent_dir}/derivatives/${subject}/func/${task}/output.tstandreg"
# subject=${8} --> ${subject}_${task}

if [ "${DO_PreProc_TissueReg_func2stand}" -eq 1 ]

then
  echo "****************************"
  echo "Running x.PreProc_TissueReg_func2stand"
  echo "****************************"

  ${home_dir}/x.PreProc_TissueReg_func2stand.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr" "usr/local/fsl/data/standard/MNI152_T1_2mm_brain" "usr/local/fsl/data/standard/MNI152_T1_2mm" "usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask_dil" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg" ${subject}_${task}

else
  echo "*******************************"
  echo "Not running x.PreProc_TissueReg_func2stand"
  echo "*******************************"
fi


################################
########## x.PreProc_Transform_lin ###############
#############################################

# # Use Transform_lin for the func2anat matrix, to transform func to anatomical... I do this step to visualize? and put T1 as an underlay?
# input_file=${1} --> the 6 outputs from the 3dbucket step vvv
# input_file_ref=${2} --> "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain"
# matrix=${3} --> "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat"
# output_dir=${4} --> "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/"
# output_prefix=${5} --> func2anat

if [ "${DO_PreProc_Transform_lin}" -eq 1 ]

then
  echo "****************************"
  echo "Running x.PreProc_Transform_lin"
  echo "****************************"

  ${home_dir}/x.PreProc_Transform_lin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_bcoef_high_force" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/" func2anat
  ${home_dir}/x.PreProc_Transform_lin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_tstat_high_force" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/" func2anat
  ${home_dir}/x.PreProc_Transform_lin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_bcoef_medium_force" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/" func2anat
  ${home_dir}/x.PreProc_Transform_lin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_tstat_medium_force" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/" func2anat
  ${home_dir}/x.PreProc_Transform_lin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_bcoef_low_force" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/" func2anat
  ${home_dir}/x.PreProc_Transform_lin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_tstat_low_force" "${parent_dir}/derivatives/${subject}/anat/T1_biascorr_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2anat" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/" func2anat

else
  echo "*******************************"
  echo "Not running x.PreProc_Transform_lin"
  echo "*******************************"
fi

################################
########## 3dbucket :D ###############
#############################################

# For all subject / task combinations:
# high force beta: 20
# high force t stat: 21
# medium force beta: 23
# medium force t stat: 24
# low force beta: 26
# low force t stat: 27

if [ "${DO_3dbucket}" -eq 1 ]

then
  echo "****************************"
  echo "3dbucket"
  echo "****************************"

  3dbucket -prefix "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bcoef_bin_force.nii.gz" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bucket.nii.gz"[20]
  3dbucket -prefix "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_tstat_bin_force.nii.gz" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bucket.nii.gz"[21]
  3dbucket -prefix "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bcoef_Nonbin_force.nii.gz" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bucket.nii.gz"[23]
  3dbucket -prefix "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_tstat_Nonbin_force.nii.gz" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bucket.nii.gz"[24]
  # 3dbucket -prefix "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_bcoef_low_force.nii.gz" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_bucket.nii.gz"[26]
  # 3dbucket -prefix "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_tstat_low_force.nii.gz" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/${subject}_${task}_bucket.nii.gz"[27]

else
  echo "*******************************"
  echo "Not running 3dbucket"
  echo "*******************************"
fi

###################################
########## x.PreProc_Transform_nonlin ##########
###################################

# input_file=${1} --> the 6 outputs from the 3dbucket step ^^^
# input_file_ref=${2} --> "${parent_dir}/derivatives/${subject}/func/${task}/output.bet/${subject}_${task}_SBREF_1_bet_ero"
# warp=${3} --> "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2stand_warp"
# output_dir=${4} --> "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC/"
# output_prefix=${5} --> func2stand

if [ "${DO_PreProc_Transform_nonlin}" -eq 1 ]

then
  echo "****************************"
  echo "Running x.PreProc_Transform_nonlin"
  echo "****************************"

  ${home_dir}/x.PreProc_Transform_nonlin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bcoef_bin_force" "usr/local/fsl/data/standard/MNI152_T1_2mm_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2stand_warp" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo" func2stand
  ${home_dir}/x.PreProc_Transform_nonlin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_tstat_bin_force" "usr/local/fsl/data/standard/MNI152_T1_2mm_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2stand_warp" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo" func2stand
  ${home_dir}/x.PreProc_Transform_nonlin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_bcoef_Nonbin_force" "usr/local/fsl/data/standard/MNI152_T1_2mm_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2stand_warp" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo" func2stand
  ${home_dir}/x.PreProc_Transform_nonlin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo/${subject}_${task}_tstat_Nonbin_force" "usr/local/fsl/data/standard/MNI152_T1_2mm_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2stand_warp" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v3_smo" func2stand
  #${home_dir}/x.PreProc_Transform_nonlin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v2/${subject}_${task}_bcoef_low_force" "usr/local/fsl/data/standard/MNI152_T1_2mm_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2stand_warp" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC" func2stand
  #${home_dir}/x.PreProc_Transform_nonlin.sh "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC_BIN_v2/${subject}_${task}_tstat_low_force" "usr/local/fsl/data/standard/MNI152_T1_2mm_brain" "${parent_dir}/derivatives/${subject}/func/${task}/output.treg/${subject}_${task}_func2stand_warp" "${parent_dir}/derivatives/${subject}/func/${task}/output.GLM_REML_OC" func2stand

else
  echo "*******************************"
  echo "Not running x.PreProc_Transform_nonlin"
  echo "*******************************"
fi

###################################
########## x.PreProc_MEANTS-4D ##########
###################################

if [ "${DO_PreProc_MEANTS-4D}" -eq 1 ]

then
  echo "****************************"
  echo "Running x.PreProc_MEANTS-4D"
  echo "****************************"

  ${home_dir}/x.PreProc_MEANTS-4D 

else
  echo "*******************************"
  echo "Not running x.PreProc_MEANTS-4D"
  echo "*******************************"
fi

done
############## END TASK LOOP ################################
done #end subject loop
