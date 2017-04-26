//
//  SPContourDetection.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPContourDetection.h"

#import "SPOpenCVHelper.h"

@implementation SPContourDetection {
    cv::Mat gray;
}

- (NSString *)name {
    return @"Contour";
}

- (void)processImage:(cv::Mat&)image {
    getGray(image, gray);
    
    cv::Mat edges;
    cv::Canny(gray, edges, 50, 150);
    
    std::vector< std::vector<cv::Point> > c;
    
    cv::findContours(edges, c, cv::RETR_LIST, cv::CHAIN_APPROX_NONE);
    
    image.copyTo(image);
    cv::drawContours(image, c, -1, cv::Scalar(0,200,0));
}

@end
