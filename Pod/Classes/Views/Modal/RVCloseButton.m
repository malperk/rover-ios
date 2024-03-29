//
//  RVCloseButton.m
//  Rover
//
//  Created by Sean Rucker on 2014-06-28.
//  Copyright (c) 2014 Rover Labs Inc. All rights reserved.
//

#import "RVCloseButton.h"

CGFloat const kWidth = 22.0;
CGFloat const kHeight = 22.0;

@implementation RVCloseButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        [self sizeToFit];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (size.width  < kWidth)  size.width  = kWidth;
    if (size.height < kHeight) size.height = kHeight;
    
    return size;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint offset = CGPointMake((rect.size.width - kWidth) / 2, (rect.size.height - kHeight) / 2);
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(offset.x + 0.5, offset.y + 0.5, kWidth - 1.0, kWidth - 1.0)];
    [UIColor.whiteColor setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(offset.x + 7.5, offset.y + 7.5)];
    [bezierPath addLineToPoint:CGPointMake(offset.x + kWidth - 7.5, offset.y + kHeight - 7.5)];
    [UIColor.whiteColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(offset.x + kWidth - 7.5, offset.y + 7.5)];
    [bezier2Path addLineToPoint:CGPointMake(offset.x + 7.5, offset.y + kHeight - 7.5)];
    [UIColor.whiteColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
}

@end
