### [**REPS**](https://www.sciencedirect.com/science/article/pii/S1569843224000955)

Codes for "**REPS: Rotation Equivariant Siamese Network Enhanced by Probability Segmentation for Satellite Video Tracking**", 
International Journal of Applied Earth Observation and Geoinformation (JAG), 2024.

- Authors: 
[Yuzeng Chen](https://yzcu.github.io/), 
[Yuqi Tang*](https://faculty.csu.edu.cn/yqtang/zh_CN/zdylm/66781/list/index.htm),
[Qiangqiang Yuan](http://qqyuan.users.sgg.whu.edu.cn/),
[Liangpei Zhang](http://www.lmars.whu.edu.cn/prof_web/zhangliangpei/rs/index.html)
- Wuhan University and Central South University
- Download the REPS codes
- Download the related OOTB dataset on [Baidu Cloud Disk (code: OOTB)](https://pan.baidu.com/s/11hsA4pOliwA1FpOqNol93w ) to your disk, the organized directory looks like:
    ```
    --OOTB/
    	|--car_1/
                |--img/
                    |--0001.jpg
                    |--...
                    |--0268.jpg
                |--groundtruth.txt
    	|...
    	|--train_10/
                |--img/
                    |--0001.jpg
                    |--...
                    |--0120.jpg
                |--groundtruth.txt
    	|--anno/
		    	|--car_1.txt
		    	|...
		    	|--train_10.txt
      	|--OOTB.json
    ```
- 🧩 Usage: Run the `./tracking/REPS.m`
- Results are saved in `./tracking/results`
- ### Visual samples
  car
 ![image](/fig/car.gif)
  train
 ![image](/fig/train.gif)

## Abstract
>Satellite video is an emerging surface observation data that has drawn increasing interest due to its potential in spatiotemporal dynamic analysis. Single object tracking of satellite videos allows the continuous acquisition of the positions and ranges of objects and establishes the correspondences in the video sequence. However, small-sized objects are vulnerable to rotation and non-rigid deformation. Moreover, the horizontal bounding box of most trackers has difficulty in providing accurate semantic representations such as object position, orientation, and spatial distribution. In this article, we propose a unified framework, named rotational equivalent Siamese network enhanced by probability segmentation (REPS), to enhance the tracking accuracy and semantic representations simultaneously. First, to deal with the inconsistency of representations, we design a rotation equivariant (RE) Siamese network architecture to detect the rotation variations of objects right from the start frame, achieving the RE tracking. Second, a pixel-level (PL) refinement is proposed to refine the spatial distribution of objects. In addition, we proposed an adaptive Gaussian fusion that synergizes tracking and segmentation results to obtain compact outputs for satellite object representations. Extensive experiments on satellite videos demonstrate the superiority of the proposed approach. The code will be available at https://github.com/YZCU/REPS.

## Overview of REPS
 ![image](/fig/REPS.jpg)
## Satellite datasets
- Dataset1 (five videos)
 ![image](/fig/Dataset1.jpg)
- Dataset2: OOTB (110 videos)
 ![image](/fig/OOTB.png)
## Results
- Results on Dataset1
 ![image](/fig/table2.jpg)
 ![image](/fig/table3.jpg)
- Success plot for overall and per-dataset on Dataset1
 ![image](/fig/fig6.jpg)
-  Overall results on OOTB
 ![image](/fig/table7.jpg)
- Success plot of per-attribute on OOTB
 ![image](/fig/fig13.jpg)
- Qualitative results of the top nine trackers on Dataset1
 ![image](/fig/fig7.jpg)


## Contact
If you have any questions or suggestions, feel free to contact me.  
Email: yuzeng_chen@whu.edu.cn 

## Citation
If you find our work helpful in your research, kindly consider citing it. We appreciate your support！

```
@article{CHEN2024103741,
title = {REPS: Rotation equivariant Siamese network enhanced by probability segmentation for satellite video tracking},
journal = {International Journal of Applied Earth Observation and Geoinformation},
volume = {128},
pages = {103741},
year = {2024},
issn = {1569-8432},
doi = {https://doi.org/10.1016/j.jag.2024.103741},
url = {https://www.sciencedirect.com/science/article/pii/S1569843224000955},
author = {Yuzeng Chen and Yuqi Tang and Qiangqiang Yuan and Liangpei Zhang},
keywords = {Video satellite, Object tracking, Siamese network, Semantic representation},
}
```
