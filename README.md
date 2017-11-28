### Introduction

This is the toolbox for [The YCB-Video database](https://rse-lab.cs.washington.edu/projects/posecnn/) introduced for 6D object pose estimation.
It provides accurate 6D poses of 21 objects from the YCB dataset observed in 92 videos with 133,827 frames.

### License

The YCB-Video dataset is released under the MIT License (refer to the LICENSE file for details).

### Citing ObjectNet3D

If you find our dataset useful in your research, please consider citing:

	@article{xiang2017posecnn,
	author    = {Xiang, Yu and Schmidt, Tanner and Narayanan, Venkatraman and Fox, Dieter},
	title     = {PoseCNN: A Convolutional Neural Network for 6D Object Pose Estimation in Cluttered Scenes},
	journal   = {arXiv preprint arXiv:1711.00199},
	year      = {2017}
	}

### Usage

1. Set your path of the YCB-Video dataset in [globals.m](https://github.com/yuxng/YCB_Video_toolbox/blob/master/globals.m) (required).

2. [show_pose_annotations.m](https://github.com/yuxng/YCB_Video_toolbox/blob/master/show_pose_annotations.m) displays the overlays of 3D shapes onto images according to our annotations. Check the code of this function to understand the annotation format.

3. [show_pose_results.m](https://github.com/yuxng/YCB_Video_toolbox/blob/master/show_pose_results.m) displays the 6D pose estimation results from PoseCNN. Unzip [results_PoseCNN.zip](https://github.com/yuxng/YCB_Video_toolbox/blob/master/results_PoseCNN.zip) before calling the function.

4. [evaluate_poses_stereo.m](https://github.com/yuxng/YCB_Video_toolbox/blob/master/evaluate_poses_stereo.m) evaluates our results on the stereo pairs. Check the code of this function to understand the evaluation metric.

5. [evaluate_poses_keyframe.m](https://github.com/yuxng/YCB_Video_toolbox/blob/master/evaluate_poses_keyframe.m) evaluates our results on the keyframes.

6. [plot_accuracy_stereo.m](https://github.com/yuxng/YCB_Video_toolbox/blob/master/plot_accuracy_stereo.m) plots all the accuracy-threshold curves from the stereo pairs.

7. [plot_accuracy_keyframe.m](https://github.com/yuxng/YCB_Video_toolbox/blob/master/plot_accuracy_keyframe.m) plots all the accuracy-threshold curves from the keyframes.
