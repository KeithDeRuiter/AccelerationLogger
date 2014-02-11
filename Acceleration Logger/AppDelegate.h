//
//  AppDelegate.h
//  Acceleration Logger
//
//  Created by Keith DeRuiter on 2/8/14.
//  Copyright (c) 2014 Keith DeRuiter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <PebbleKit/PebbleKit.h>
#import "AccelerationLogger.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    CMMotionManager *_motionManager;
    AccelerationLogger *accelLoggerPebble;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly) CMMotionManager *motionManager;
@property (strong, nonatomic) ViewController *viewController;

+ (NSString *) applicationDocumentsDirectory;
-(void) clearFiles;


@end
