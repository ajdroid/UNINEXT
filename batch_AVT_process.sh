#!/bin/bash
function string_replace {
    echo "${1//\*/$2}"
}

# setup model variables
DO_SEG=true

# append the .pt
MODEL_NAME=video_joint_vit_huge
# video_joint_vit_huge_eval_mots_AVT
# Data source
# IMGS_DIR="custom_"${HOME}"/datasets/avtfcw-videos/traffic_frames_padbottom/evoque_2016k_031_20170119_1319_9238_2399_traffic"

 #multi object tracking or MOT+segmentation 
if [ $DO_SEG = true ] ; then
    TASK="mots"
else
    TASK="mot"
fi
CONFIG_FILENAME=${MODEL_NAME}"_eval_"${TASK}"_AVT-full-part"

template_launch_cmd="CUDA_VISIBLE_DEVICES=* python launch.py --nn 1 --np 1 --eval-only --uni 1  \
--config-file  projects/UNINEXT/configs/eval-avt/${CONFIG_FILENAME}*.yaml \
--resume \
OUTPUT_DIR outputs/${MODEL_NAME} \
MODEL.USE_IOU_BRANCH False" 
# DATASETS.TEST ${IMGS_DIR}
# "


NUM_GPUs=8 # you have created the right number of images
tmux new-session -d -s UNINEXT
#tmux set-option remain-on-exit on
for (( gpu_num=0; gpu_num<NUM_GPUs ; gpu_num++))
do
    # launch tmux windows
    mod_launch_cmd=$(string_replace "$template_launch_cmd" ${gpu_num})
    tmux_cmd="echo '${mod_launch_cmd}'"
    eval ${tmux_cmd}
    window_num=$((gpu_num+2))
    tmux new-window -t UNINEXT:$window_num -n "GPU "${gpu_num}
    tmux send-keys -t UNINEXT:$window_num "conda activate dataprep" C-m
    tmux send-keys -t UNINEXT:$window_num "${mod_launch_cmd}" C-m
done

#finally, attach to session
tmux attach-session -d -t UNINEXT
