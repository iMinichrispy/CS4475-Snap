//
//  SPSepiaEffect.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPSepiaEffect.h"

@implementation SPSepiaEffect {
    cv::Mat_<float> m_sepiaKernel;
    cv::Mat_<float> m_sepiaKernelT;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        m_sepiaKernel.create(4, 4);
        
        m_sepiaKernel(0,0) = 0.272; m_sepiaKernel(0,1) = 0.534; m_sepiaKernel(0,2) = 0.131; m_sepiaKernel(0,3) = 0;
        m_sepiaKernel(1,0) = 0.349; m_sepiaKernel(1,1) = 0.686; m_sepiaKernel(1,2) = 0.168; m_sepiaKernel(1,3) = 0;
        m_sepiaKernel(2,0) = 0.393; m_sepiaKernel(2,1) = 0.769; m_sepiaKernel(2,2) = 0.189; m_sepiaKernel(2,3) = 0;
        m_sepiaKernel(3,0) = 0;     m_sepiaKernel(3,1) = 0;     m_sepiaKernel(3,2) = 0;     m_sepiaKernel(3,3) = 1;
        
        cv::transpose(m_sepiaKernel, m_sepiaKernelT);
    }
    return self;
}

- (NSString *)name {
    return @"Sepia";
}

- (void)effect:(SPEffect *)effect processImage:(cv::Mat&)image {
    cv::transform(image, image, m_sepiaKernel);
}

@end
