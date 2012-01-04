//
//  MGADropShadowView.h
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import <UIKit/UIKit.h>

typedef enum {
    kLEFT,
    kRIGHT,
    kDOWN,
    kUP
} ShadowDirection;

@interface MGADropShadowView : UIView

-(void) setShadowDirection:(ShadowDirection) direction;

@end
