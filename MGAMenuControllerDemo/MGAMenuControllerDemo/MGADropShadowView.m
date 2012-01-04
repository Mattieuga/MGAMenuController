//
//  MGADropShadowView.m
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import "MGADropShadowView.h"

@interface MGADropShadowView() {
@private
    ShadowDirection shadowDirection;
}
@end

@implementation MGADropShadowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGRect wrapperRectangle;
    wrapperRectangle = CGRectMake(rect.origin.x + ((shadowDirection == kLEFT) ? 20 : 0), 
                                  rect.origin.y, 
                                  rect.size.width-20,
                                  rect.size.height);
    
    // Draw the background rectangle.
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextAddRect(context, wrapperRectangle);
    
    CGSize baseTranslation;
    if (shadowDirection == kLEFT)
        baseTranslation = CGSizeMake(-10.0f, 0.0f);
    else if (shadowDirection == kRIGHT)
        baseTranslation = CGSizeMake(10.0f, 0.0f);
    else if (shadowDirection == kDOWN)
        baseTranslation = CGSizeMake(0.0f, 10.0f);
    else if (shadowDirection == kUP)
        baseTranslation = CGSizeMake(0.0f, -10.0f);
    
    CGContextSetShadowWithColor(context, baseTranslation, 7.0f, [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.40] CGColor]);
    CGContextFillPath(context);
    
    // Draw content.
    UIGraphicsPushContext(context);
    
    // Cleanup. 
    CGColorSpaceRelease(colorspace); 
}

-(void) setShadowDirection:(ShadowDirection) direction {
    shadowDirection = direction;
}
@end
