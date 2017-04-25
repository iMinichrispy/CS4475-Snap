//
//  SPEdgeDetection.m
//  Snap
//
//  Created by Alex Perez on 4/24/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPEdgeDetection.h"

#import "SPOpenCVHelper.h"

@implementation SPEdgeDetection {
    cv::Mat grayImage;
    cv::Mat edges;
    
    cv::Mat grad_x, grad_y;
    cv::Mat abs_grad_x, abs_grad_y;
    
    cv::Mat dst;
    cv::Mat dst_norm, dst_norm_scaled;
    
    bool m_showOnlyEdges;
    std::string m_algorithmName;
    
    // Canny detector options:
    int m_cannyLoThreshold;
    int m_cannyHiThreshold;
    int m_cannyAperture;
    
    // Harris detector options:
    int m_harrisBlockSize;
    int m_harrisapertureSize;
    double m_harrisK;
    int m_harrisThreshold;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        m_showOnlyEdges = false;
        m_algorithmName = "Canny";
        
        m_cannyLoThreshold = 190; // 0-256
        m_cannyHiThreshold = 220; // 0-256
        m_cannyAperture = 1; // 1-3
        
        m_harrisBlockSize = 2;
        m_harrisapertureSize = 3;
        m_harrisK = 0.04f;
        m_harrisThreshold = 200;
    }
    return self;
}

- (NSString *)name {
    return @"Edges";
}

- (void)effect:(SPEffect *)effect processImage:(cv::Mat&)image {
    getGray(image, grayImage);
    
    if (m_algorithmName == "Canny")
    {
        cv::Canny(grayImage, edges, m_cannyLoThreshold, m_cannyHiThreshold, m_cannyAperture * 2 + 1);
    }
    else if (m_algorithmName == "Sobel")
    {
        int scale = 1;
        int delta = 0;
        int ddepth = CV_16S;
        
        /// Gradient X
        cv::Sobel( grayImage, grad_x, ddepth, 1, 0, 3, scale, delta, cv::BORDER_DEFAULT );
        cv::convertScaleAbs( grad_x, abs_grad_x );
        
        /// Gradient Y
        cv::Sobel( grayImage, grad_y, ddepth, 0, 1, 3, scale, delta, cv::BORDER_DEFAULT );
        cv::convertScaleAbs( grad_y, abs_grad_y );
        
        /// Total Gradient (approximate)
        cv::addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, edges );
    }
    else if (m_algorithmName == "Schaar")
    {
        int scale = 1;
        int delta = 0;
        int ddepth = CV_16S;
        
        /// Gradient X
        cv::Scharr( grayImage, grad_x, ddepth, 1, 0, scale, delta, cv::BORDER_DEFAULT );
        cv::convertScaleAbs( grad_x, abs_grad_x );
        
        /// Gradient Y
        cv::Scharr( grayImage, grad_y, ddepth, 0, 1, scale, delta, cv::BORDER_DEFAULT );
        cv::convertScaleAbs( grad_y, abs_grad_y );
        
        /// Total Gradient (approximate)
        cv::addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, edges );
    }
    else if (m_algorithmName == "Harris")
    {
        /// Detecting corners
        cv::cornerHarris( grayImage, dst, m_harrisBlockSize, m_harrisapertureSize, m_harrisK, cv::BORDER_DEFAULT );
        
        /// Normalizing
        cv::normalize( dst, dst_norm, 0, 255, cv::NORM_MINMAX, CV_32FC1, cv::Mat() );
        cv::convertScaleAbs( dst_norm, dst_norm_scaled );
        
        //edges = dst_norm_scaled;
        /// Drawing a circle around corners
        cv::threshold(dst_norm_scaled, edges, m_harrisThreshold, 255, cv::THRESH_BINARY);
        /*
         for( int j = 0; j < dst_norm.rows ; j++ )
         {
         for( int i = 0; i < dst_norm.cols; i++ )
         {
         if( (int) dst_norm.at<float>(j,i) > m_harrisThreshold )
         {
         circle( dst_norm_scaled, cv::Point( i, j ), 5,  cv::Scalar(0), 2, 8, 0 );
         }
         }
         }*/
        
        //edges = dst_norm_scaled;
        //cv::cvtColor(dst_norm_scaled, outputFrame, cv::COLOR_GRAY2BGRA);
    }
    else
    {
        std::cerr << "Unsupported algorithm:" << m_algorithmName << std::endl;
        assert(false);
    }
    
    if (m_showOnlyEdges)
    {
        cv::cvtColor(edges, image, cv::COLOR_GRAY2BGRA);
    }
    else 
    {
        cv::cvtColor(grayImage * 0.25 +  0.75 * edges, image, cv::COLOR_GRAY2BGRA);
    }
}

@end
