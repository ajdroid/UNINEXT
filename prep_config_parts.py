import os
import glob

config_str_template = '''## main setting (ViT-huge video-level joint training)
_BASE_: "../video_joint_vit_huge.yaml" # all video tasks joint training
DATASETS:
  TEST: %s
INPUT:
  MIN_SIZE_TEST: 800

'''

dir_list = glob.glob("/home/abhijatbiswas/datasets/avtfcw-videos/bdd_task_seg_track_20/traffic_videos_fillborder/*/")
NUM_GPUs = 8

ec2_dirlist = [[] for _ in range(NUM_GPUs)]
for i, dir_name in enumerate(sorted(dir_list)):
    dir_name = dir_name.replace("abhijatbiswas", "ubuntu")
    dir_name = "custom_" + dir_name 
    ec2_dirlist[i%NUM_GPUs].append(dir_name)

# write to NUM_GPUs config files
config_file_dir="projects/UNINEXT/configs/eval-avt"
model_name="vit_huge"
task="mots"
# video_joint_vit_huge_eval_mots_AVT-full.yaml

print("splitting %d files among %d GPUs" %( len(dir_list), NUM_GPUs))

for j in range(NUM_GPUs):
    config_filename=os.path.join(config_file_dir, \
        "video_joint_"+model_name+"_eval_"+task+"_AVT-full-part"+str(j)+".yaml")
    config_str = config_str_template % str(tuple(ec2_dirlist[j]))
    with open(config_filename, 'w') as f:
        f.write(config_str)
print("Done writing")