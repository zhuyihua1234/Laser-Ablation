"Otsu_image_segmenter.m": This program utilizes MATLAB's Image Segmenter to segment ROI from laser images. It combines with a Island Segmentation at the end to prepare the segmentation for ablation.

"Contrast_based_segmenter.m": This program automatically detects the mean pixel intensity of the image. It applies a transformation of (Il-Is)/Il to every pixel, where Is is the mean pixel intensity of the image. Threshold can be adjusted as the fraction of the mean intensity. This program segments the ROI based on 0.1 contrast method.

"dark_corner_correction.mat": This file contains the inverse map of dark corner correction used for CO2 laser
