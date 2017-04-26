//
//  SPMouthDetection.m
//  Snap
//
//  Created by Alex Perez on 4/26/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPMouthDetection.h"

const int HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

@implementation SPMouthDetection {
    cv::CascadeClassifier faceCascade;
    cv::CascadeClassifier noseCascade;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString* faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        if (!faceCascade.load([faceCascadePath UTF8String])) {
            NSLog(@"Error loading face cascade");
        }
        
        NSString* nosePath = [[NSBundle mainBundle] pathForResource:@"Nose" ofType:@"xml"];
        if (!noseCascade.load([nosePath UTF8String])) {
            NSLog(@"Error loading face cascade");
        }
    }
    return self;
}

- (NSString *)name {
    return @"Mouth";
}

- (void)processImage:(cv::Mat&)image {
    cv::Mat gray;
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    
    std::vector<cv::Rect> faces;
    
    faceCascade.detectMultiScale(image, faces, 1.1, 2, HaarOptions, cv::Size(60, 60));
    
    for (int i = 0; i < faces.size(); i++)
    {
        cv::Rect face = faces[i];
        cv::Point pt1(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
        cv::Point pt2(faces[i].x, faces[i].y);
        
        // Draw rectangle around face
        cv::rectangle(image, faces[i], 1234);
        
        cv::Mat roi_gray = gray(faces[i]);
        cv::Mat roi_color = image(faces[i]);
        
        
//        cv::Mat roi_gray = gray[y:y+h, x:x+w];
//        roi_color = frame[y:y+h, x:x+w]
        
        std::vector<cv::Rect> noses;
        noseCascade.detectMultiScale(image, noses, 1.1, 2, HaarOptions, cv::Size(60, 60));
        
        for (int i = 0; i < noses.size(); i++) {
            // Draw rectangle around nose
            cv::Rect nose = noses[i];
            cv::Rect offset_nose;
            offset_nose.x = face.x;
            offset_nose.y = face.y;
            offset_nose.width = nose.width;
            offset_nose.height = nose.height;
            
//            cv::Rect offset_nose = Rect(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
            cv::rectangle(image, offset_nose, 1234);
        }
    }
    if (faces.size() > 0) {
        
//        [self findEyes:grayscaleFrame withFace:faces[0] output:image];
    }
}

@end
