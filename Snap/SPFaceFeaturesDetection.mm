//
//  SPFaceFeaturesDetection.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPFaceFeaturesDetection.h"

#include "ObjectTrackingClass.h"
#import "SPOpenCVHelper.h"

const int HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

typedef NS_ENUM(NSInteger, EyePosition) {
    EyePositionNone,
    EyePositionTop,
    EyePositionBottom
};

@interface SPFaceFeaturesDetection ()

@end

@implementation SPFaceFeaturesDetection {
    EyePosition eyePosition;
    BOOL eyesAreTop;
    NSInteger * framesAtPosition;
    cv::CascadeClassifier faceCascade;
    
    
    
    // object detection
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
        
        NSString* faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        if (!faceCascade.load([faceCascadePath UTF8String])) {
            NSLog(@"Error loading face cascade");
        }
        
        m_algorithmName = "LKT";
        m_maxCorners = 200;
    }
    return self;
}

- (NSString *)name {
    return @"Features";
}

- (NSString *)tagline {
    return @"OpenCV";
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
    cv::Mat grayscaleFrame;
    grayscaleFrame = image;
//    cvtColor(image, grayscaleFrame, CV_BGR2GRAY);
//    equalizeHist(grayscaleFrame, grayscaleFrame);
    
    std::vector<cv::Rect> faces;
    
    faceCascade.detectMultiScale(grayscaleFrame, faces, 1.1, 2, HaarOptions, cv::Size(60, 60));
    
    for (int i = 0; i < faces.size(); i++)
    {
        cv::Point pt1(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
        cv::Point pt2(faces[i].x, faces[i].y);
        
//        Scalar(B,G,R);
        cv::rectangle(image, faces[i], cv::Scalar(0, 0, 255), 3);
    }
    if (faces.size() > 0) {
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
        
#if DEBUG
        cv::Rect faceRect = faces[0];
#else
        cv::Rect faceRect = cv::Rect(0,0,0,0);
#endif
        
        // begin tracking object
        if ( trackObject ) {
            ot.track(image,
                     imagePrev,
                     imageNext,
                     pointsPrev,
                     pointsNext,
                     status,
                     err,
                     faceRect);
            
            size_t i, k;
            for( i = k = 0; i < pointsNext.size(); i++ )
            {
                if( !status[i] )
                    continue;
                
                cv::Point2f point = pointsNext[i];
                
                
            }
            
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
}

@end
