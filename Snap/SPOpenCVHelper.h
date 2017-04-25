//
//  SPOpenCVHelper.h
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif

void getGray(const cv::Mat& input, cv::Mat& gray);

@interface SPOpenCVHelper : NSObject

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
