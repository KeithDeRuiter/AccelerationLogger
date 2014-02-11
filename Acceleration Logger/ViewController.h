//
//  ViewController.h
//  Acceleration Logger
//
//  Created by Keith DeRuiter on 2/8/14.
//  Copyright (c) 2014 Keith DeRuiter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccelerationLogger.h"

@interface ViewController : UIViewController {
    AccelerationLogger *accelLoggerPhone;
}

-(void) startMotionDetect;

@end
