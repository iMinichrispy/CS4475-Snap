//
//  SPEyeDetection.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPEyeDetection.h"

#import "PupilTracking.h"
#include "ObjectTrackingClass.h"
#import "SPOpenCVHelper.h"

const int HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

typedef NS_ENUM(NSInteger, EyePosition) {
    EyePositionNone,
    EyePositionTop,
    EyePositionBottom
};

@interface SPEyeDetection ()

@property (nonatomic, strong) PupilTracking* pupilTracking;

@end

@implementation SPEyeDetection {
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
//        self.pupilTracking = [PupilTracking alloc];
//        [self.pupilTracking initialiseVars];
//        [self.pupilTracking createCornerKernels];
        
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
    return @"Eyes";
}

- (void)handleTouchFrame:(const cv::Mat&)frame {
    getGray(frame, imagePrev);
    computeObject = true;
}

- (void)start {
    [self.pupilTracking releaseCornerKernels];
    self.pupilTracking = [PupilTracking alloc];
    [self.pupilTracking initialiseVars];
    [self.pupilTracking createCornerKernels];
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
        cv::Rect faceRect = Rect(0,0,0,0);
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
        
//
//        [self findEyes:grayscaleFrame withFace:faces[0] output:image];
    }
}

- (void) findEyes:(cv::Mat)frame withFace: (cv::Rect) face output:(cv::Mat&) outputFrame {
//    cv::Mat faceROI = frame(face); // scales frame to face rect
    cv::Mat faceROI = frame;
    //cv::Mat debugFace;
    
    if (self.pupilTracking.SmoothFaceImage) {
        double sigma = self.pupilTracking.SmoothFaceFactor * face.width;
        GaussianBlur( faceROI, faceROI, cv::Size( 0, 0 ), sigma);
    }
    
    //-- Find eye regions and draw them (face box)
    int eye_region_width = face.width * (self.pupilTracking.EyePercentWidth/100.0);
    int eye_region_height = face.width * (self.pupilTracking.EyePercentHeight/100.0);
    int eye_region_top = face.height * (self.pupilTracking.EyePercentTop/100.0);
    cv::Rect leftEyeRegion(face.width*(self.pupilTracking.EyePercentSide/100.0),
                           eye_region_top,eye_region_width,eye_region_height);
    cv::Rect rightEyeRegion(face.width - eye_region_width - face.width*(self.pupilTracking.EyePercentSide/100.0),
                            eye_region_top,eye_region_width,eye_region_height);
    
    //-- Find Eye Centers
    
    cv::Point leftPupil = [self.pupilTracking findEyeCenter:outputFrame withEye:leftEyeRegion withOutput:outputFrame];
    cv::Point rightPupil = [self.pupilTracking findEyeCenter:outputFrame withEye:rightEyeRegion withOutput:outputFrame];
    // get corner regions
    cv::Rect leftRightCornerRegion(leftEyeRegion);
    leftRightCornerRegion.width -= leftPupil.x;
    leftRightCornerRegion.x += leftPupil.x;
    leftRightCornerRegion.height /= 2;
    leftRightCornerRegion.y += leftRightCornerRegion.height / 2;
    cv::Rect leftLeftCornerRegion(leftEyeRegion);
    leftLeftCornerRegion.width = leftPupil.x;
    leftLeftCornerRegion.height /= 2;
    leftLeftCornerRegion.y += leftLeftCornerRegion.height / 2;
    cv::Rect rightLeftCornerRegion(rightEyeRegion);
    rightLeftCornerRegion.width = rightPupil.x;
    rightLeftCornerRegion.height /= 2;
    rightLeftCornerRegion.y += rightLeftCornerRegion.height / 2;
    cv::Rect rightRightCornerRegion(rightEyeRegion);
    rightRightCornerRegion.width -= rightPupil.x;
    rightRightCornerRegion.x += rightPupil.x;
    rightRightCornerRegion.height /= 2;
    rightRightCornerRegion.y += rightRightCornerRegion.height / 2;
    rectangle(faceROI,leftRightCornerRegion,200);
    rectangle(faceROI,leftLeftCornerRegion,200);
    rectangle(faceROI,rightLeftCornerRegion,200);
    rectangle(faceROI,rightRightCornerRegion,200);
    
    // change eye centers to face coordinates
    rightPupil.x += rightEyeRegion.x;
    rightPupil.y += rightEyeRegion.y;
    leftPupil.x += leftEyeRegion.x;
    leftPupil.y += leftEyeRegion.y;
    // draw eye centers
    circle(faceROI, rightPupil, 3, 1234);
    circle(faceROI, leftPupil, 3, 1234);
    
    /*
//    printf("Right (%d, %d), Left (%d, %d)\n", rightPupil.x, rightPupil.y, leftPupil.x, leftPupil.y);
    //-- Find Eye Corners
    if (self.pupilTracking.EnableEyeCorner) {
        //        cv::Point2f leftRightCorner = findEyeCorner(faceROI(leftRightCornerRegion), true, false);
        cv::Point2f leftRightCorner = [self.pupilTracking findEyeCorner:faceROI(leftRightCornerRegion) withLeft:true withLeft2:false];
        leftRightCorner.x += leftRightCornerRegion.x;
        leftRightCorner.y += leftRightCornerRegion.y;
        cv::Point2f leftLeftCorner = [self.pupilTracking findEyeCorner:faceROI(leftLeftCornerRegion) withLeft:true withLeft2:true];
        leftLeftCorner.x += leftLeftCornerRegion.x;
        leftLeftCorner.y += leftLeftCornerRegion.y;
        cv::Point2f rightLeftCorner = [self.pupilTracking findEyeCorner:faceROI(rightLeftCornerRegion) withLeft:false withLeft2:true];
        rightLeftCorner.x += rightLeftCornerRegion.x;
        rightLeftCorner.y += rightLeftCornerRegion.y;
        cv::Point2f rightRightCorner = [self.pupilTracking findEyeCorner:faceROI(rightRightCornerRegion) withLeft:false withLeft2:false];
        rightRightCorner.x += rightRightCornerRegion.x;
        rightRightCorner.y += rightRightCornerRegion.y;
        circle(faceROI, leftRightCorner, 3, 200);
        circle(faceROI, leftLeftCorner, 3, 200);
        circle(faceROI, rightLeftCorner, 3, 200);
        circle(faceROI, rightRightCorner, 3, 200);
    }
    
    
    framesAtPosition++;
    
    if((NSInteger)framesAtPosition > 15) {
        if ((rightPupil.y + leftPupil.y) / 2 > 40){
            eyesAreTop = TRUE;
            eyePosition = EyePositionTop;
            //stop the camera and move to next slide
        } else if ((rightPupil.y + leftPupil.y) / 2 < 35){
            eyesAreTop = FALSE;
            eyePosition = EyePositionBottom;
        }
        framesAtPosition = 0;
    }
    */
    faceROI.copyTo(outputFrame);
    
}

@end
