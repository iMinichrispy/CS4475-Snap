//
//  SPRectOperations.m
//  Snap
//
//  Created by Alex Perez on 5/4/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPRectOperations.h"

CGRect SPAverageRect(CGRect rect1, CGRect rect2) {
    CGFloat averageX = (rect1.origin.x + rect2.origin.x) / 2.0f;
    CGFloat averageY = (rect1.origin.y + rect2.origin.y) / 2.0f;
    CGFloat averageWidth = (rect1.size.width + rect2.size.width) / 2.0f;
    CGFloat averageHeight = (rect1.size.height + rect2.size.height) / 2.0f;
    CGRect averageRect = CGRectMake(averageX, averageY, averageWidth, averageHeight);
    return averageRect;
}
