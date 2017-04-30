//
//  SPMouthDetection.m
//  Snap
//
//  Created by Alex Perez on 4/26/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPMouthDetection.h"

const int HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH | CV_HAAR_SCALE_IMAGE;

@implementation SPMouthDetection {
    cv::CascadeClassifier faceCascade;
    cv::CascadeClassifier eyesCascade;
    cv::CascadeClassifier noseCascade;
    cv::CascadeClassifier mouthCascade;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString* faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        if (!faceCascade.load([faceCascadePath UTF8String])) {
            NSLog(@"Error loading face cascade");
        }
        
        NSString* eyesPath = [[NSBundle mainBundle] pathForResource:@"haarcascade_eye_tree_eyeglasses" ofType:@"xml"];
        if (!eyesCascade.load([eyesPath UTF8String])) {
            NSLog(@"Error loading eyes cascade");
        }
        
        NSString* nosePath = [[NSBundle mainBundle] pathForResource:@"Nose" ofType:@"xml"];
        if (!noseCascade.load([nosePath UTF8String])) {
            NSLog(@"Error loading nose cascade");
        }

    
        NSString* mouthPath = [[NSBundle mainBundle] pathForResource:@"Mouth" ofType:@"xml"];
        if (!mouthCascade.load([mouthPath UTF8String])) {
            NSLog(@"Error loading mouth cascade");
        }
    }
    return self;
}

- (NSString *)name {
    return @"Mouth";
}

- (void)processImage:(cv::Mat&)frame {
    std::vector<cv::Rect> faces;
    cv::Mat grayframe;
    
    cvtColor(frame,grayframe, CV_BGR2GRAY);
    equalizeHist(grayframe,frame);
    
    faceCascade.detectMultiScale(frame, faces,1.1,3,   CV_HAAR_SCALE_IMAGE|CV_HAAR_DO_ROUGH_SEARCH,cv::Size(30,30));
    for(int i=0;i<faces.size();i++)
    {
        rectangle(frame,faces[i],cv::Scalar(255,0,0),1,8,0);
        cv::Mat face  = frame(faces[i]);
//        cvtColor(face,face,CV_BGR2GRAY);
        std::vector<cv::Rect> mouthi;
        mouthCascade.detectMultiScale(face,mouthi,1.1,3,  CV_HAAR_SCALE_IMAGE|CV_HAAR_DO_ROUGH_SEARCH,cv::Size(30,30));
        for(int k=0;k<mouthi.size();k++)
        {
            cv::Point pt1(mouthi[0].x+faces[i].x , mouthi[0].y+faces[i].y);
            cv::Point pt2(pt1.x+mouthi[0].width, pt1.y+mouthi[0].height);
            cv::rectangle(frame, pt1,pt2,cv::Scalar(255,0,0),1,8,0);
        }
    }

    /*
    std::vector<cv::Rect> faces;
    cv::Mat frame_gray;
    
    cvtColor( frame, frame_gray, CV_BGR2GRAY );
    equalizeHist( frame_gray, frame_gray );
    
    //-- Detect faces
    faceCascade.detectMultiScale( frame_gray, faces, 1.1, 2, HaarOptions, cv::Size(30, 30) );
    
    for( size_t i = 0; i < faces.size(); i++ )
    {
        cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
        ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
        
        cv::Mat faceROI = frame_gray( faces[i] );
        std::vector<cv::Rect> eyes;
        
        //-- In each face, detect eyes
        eyesCascade.detectMultiScale( faceROI, eyes, 1.1, 2, HaarOptions, cv::Size(30, 30) );
        
        for( size_t j = 0; j < eyes.size(); j++ )
        {
            cv::Point center( faces[i].x + eyes[j].x + eyes[j].width*0.5, faces[i].y + eyes[j].y + eyes[j].height*0.5 );
            int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25 );
            cv::circle( frame, center, radius, cv::Scalar( 255, 0, 0 ), 4, 8, 0 );
        }
    }*/
    
    
    /*
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
        
        for (int i = 0; i < faces.size(); i++)
        {
//            rectangle(frame, faces[i], Scalar(255, 0, 0), 1, 8, 0);
//            Mat face = frame(faces[i]);
//            cvtColor(face, face, CV_BGR2GRAY);
//            vector<Rect> mouthi;
//            mouth.detectMultiScale(face, mouthi);
//            
//            for (int k = 0; k < mouthi.size(); k++)
//            {
//                
//            }
        }
        
        
        
        for (int i = 0; i < noses.size(); i++) {
//            cv::Rect nose = noses[i];
            cv::Point pt1(noses[0].x + faces[i].x, noses[0].y + faces[i].y);
            cv::Point pt2(pt1.x + noses[0].width, pt1.y + noses[0].height);
//            cv::rectangle(image, pt1, pt2, cv::Scalar(255, 0, 0), 1, 8, 0);
            
             cv::Mat mouth_image = image(cv::Rect(pt1, pt2));
            cv::rectangle(image, mouth_image, 1234);
            
            // Draw rectangle around nose
//            cv::Rect nose = noses[i];
//            cv::Rect offset_nose;
//            offset_nose.x = face.x;
//            offset_nose.y = face.y;
//            offset_nose.width = nose.width;
//            offset_nose.height = nose.height;
//            
////            cv::Rect offset_nose = Rect(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
//            cv::rectangle(image, offset_nose, 1234);
        }
    }
    if (faces.size() > 0) {
        
//        [self findEyes:grayscaleFrame withFace:faces[0] output:image];
    }*/
}

@end
