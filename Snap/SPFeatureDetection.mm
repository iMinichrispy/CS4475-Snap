//
//  SPFeatureDetection.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPFeatureDetection.h"

#import "SPOpenCVHelper.h"

#define kDetectorORB   "ORB"
#define kDetectorAKAZE "AKAZE"
#define kDetectorFAST  "FAST"

static bool keypoint_score_greater(const cv::KeyPoint& kp1, const cv::KeyPoint& kp2)
{
    return kp1.response > kp2.response;
}

@implementation SPFeatureDetection {
    cv::Mat grayImage;
    
    std::vector<cv::KeyPoint> objectKeypoints;
    
    std::string m_detectorName;
    std::vector<std::string> m_alorithms;
    
    cv::Ptr<cv::ORB>  m_ORB;
    cv::Ptr<cv::AKAZE> m_AKAZE;
    cv::Ptr<cv::FastFeatureDetector> m_FAST;
    
    int m_maxFeatures;
    int m_fastThreshold;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        m_maxFeatures = 100;
        m_fastThreshold = 10;
        
        m_ORB = cv::ORB::create();
        m_FAST = cv::FastFeatureDetector::create();
        m_AKAZE = cv::AKAZE::create();
        
        m_detectorName = kDetectorORB;
    }
    return self;
}

- (NSString *)name {
    return @"Features";
}

- (void)effect:(SPEffect *)effect processImage:(cv::Mat&)image {
    // convert input frame to gray scale
    getGray(image, grayImage);
    
    
    if (m_detectorName == kDetectorORB)
    {
        m_ORB->detect(grayImage, objectKeypoints);
    }
    else if (m_detectorName == kDetectorFAST)
    {
        m_FAST->detect(grayImage, objectKeypoints);
    }
    else if (m_detectorName == kDetectorAKAZE)
    {
        m_AKAZE->detect(grayImage, objectKeypoints);
    }
    
    cv::KeyPointsFilter::retainBest(objectKeypoints, m_maxFeatures);
    
    if (objectKeypoints.size() > m_maxFeatures)
    {
        std::sort(objectKeypoints.begin(), objectKeypoints.end(), keypoint_score_greater);
        objectKeypoints.resize(m_maxFeatures);
    }
    
    cv::Mat t;
    cv::cvtColor(image, t, cv::COLOR_BGRA2BGR);
    cv::drawKeypoints(t, objectKeypoints, t, cv::Scalar::all(-1), cv::DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
    
    cv::cvtColor(t, image, cv::COLOR_BGR2BGRA);
}

@end
