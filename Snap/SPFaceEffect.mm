//
//  SPFaceEffect.m
//  Snap
//
//  Created by Alex Perez on 5/3/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPFaceEffect.h"

const int HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

@implementation SPFaceEffect {
    cv::CascadeClassifier faceCascade;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString* faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        if (!faceCascade.load([faceCascadePath UTF8String])) {
            NSLog(@"Error loading face cascade");
        }
    }
    return self;
}

- (NSString *)name {
    return @"Face";
}

- (NSString *)tagline {
    return @"OpenCV";
}

- (void)processImage:(cv::Mat&)image {
    cv::Mat grayscaleFrame;
    grayscaleFrame = image;
    
    std::vector<cv::Rect> faces;
    
    faceCascade.detectMultiScale(grayscaleFrame, faces, 1.1, 2, HaarOptions, cv::Size(60, 60));
    
    for (int i = 0; i < faces.size(); i++)
    {
        cv::Point pt1(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
        cv::Point pt2(faces[i].x, faces[i].y);
        
        cv::rectangle(image, faces[i], cv::Scalar(0, 0, 255), 3);
    }
}

@end
