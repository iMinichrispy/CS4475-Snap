//
//  SPObjectDetection.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPObjectDetection.h"

#include "ObjectTrackingClass.h"
#import "SPOpenCVHelper.h"

bool computeObject = false;
bool detectObject = false;
bool trackObject = false;

@implementation SPObjectDetection {
    cv::Mat imageNext, imagePrev;
    
    std::vector<uchar> status;
    
    std::vector<float> err;
    
    std::string m_algorithmName;
    
    std::vector<cv::Point2f> pointsPrev, pointsNext;
    
    // optical flow options
    int m_maxCorners;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        m_algorithmName = "LKT";
        m_maxCorners = 200;
    }
    return self;
}

- (NSString *)name {
    return @"Objects";
}

- (NSString *)prompt {
    return @"Tap an Object";
}

- (void)effect:(SPEffect *)effect handleTouchReferenceFrame:(const cv::Mat&)reference {
    getGray(reference, imagePrev);
    computeObject = true;
}

- (void)effect:(SPEffect *)effect processImage:(cv::Mat&)image {
    // display the frame
    image.copyTo(image);
    
    // convert input frame to gray scale
    getGray(image, imageNext);
    
    // prepare the tracking class
    ObjectTrackingClass ot;
    ot.setMaxCorners(m_maxCorners);
    
    // begin tracking object
    if ( trackObject ) {
        ot.track(image,
                 imagePrev,
                 imageNext,
                 pointsPrev,
                 pointsNext,
                 status,
                 err);
        
        // check if the next points array isn't empty
        if ( pointsNext.empty() )
            trackObject = false;
    }
    
    // store the reference frame as the object to track
    if ( computeObject ) {
        ot.init(image, imagePrev, pointsNext);
        trackObject = true;
        computeObject = false;
    }
    
    // backup previous frame
    imageNext.copyTo(imagePrev);
    
    // backup points array
    std::swap(pointsNext, pointsPrev);
}

@end
