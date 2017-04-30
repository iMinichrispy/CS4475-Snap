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

@implementation SPObjectDetection {
    cv::Mat imageNext, imagePrev;
    
    std::vector<uchar> status;
    
    std::vector<float> err;
    
    std::string m_algorithmName;
    
    std::vector<cv::Point2f> pointsPrev, pointsNext;
    
    // optical flow options
    int m_maxCorners;
    
    bool computeObject;
    bool detectObject;
    bool trackObject;
    
    bool tracking;
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
    return @"Tap to Reset";
}

- (void)handleTouchFrame:(const cv::Mat&)frame {
    getGray(frame, imagePrev);
    computeObject = true;
}

- (void)stop {
    computeObject = false;
    detectObject = false;
    trackObject = false;
    tracking = false;
}

- (void)processImage:(cv::Mat&)image {
    if (!imagePrev.empty() && !tracking) {
        [self handleTouchFrame:imagePrev];
        tracking = true;
    }
    
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
                 err,
                 cv::Rect(0,0,0,0));
        
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
