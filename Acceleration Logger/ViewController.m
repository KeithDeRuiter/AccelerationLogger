//
//  ViewController.m
//  Acceleration Logger
//
//  Created by Keith DeRuiter on 2/8/14.
//  Copyright (c) 2014 Keith DeRuiter. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    accelLoggerPhone = [[AccelerationLogger alloc] initWithFileFlair:@"Phone"];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"VIEW APPEARED!");
    
    [super viewDidAppear:animated];
    
    [self startMotionDetect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.motionManager stopAccelerometerUpdates];
    
}

- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    
    return motionManager;
}

- (void)startMotionDetect
{
    
    self.motionManager.accelerometerUpdateInterval = 0.1f;
    [self.motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{   //Will be called with data and error
                            QuietLog(@"PHONE  X: %.2f, Y: %.2f, Z: %.2f", data.acceleration.x, data.acceleration.y, data.acceleration.z);
                            [accelLoggerPhone logData:data];
                        }
                        );
     }
     ];
    
}

@end
