//
//  AppDelegate.m
//  Acceleration Logger
//
//  Created by Keith DeRuiter on 2/8/14.
//  Copyright (c) 2014 Keith DeRuiter. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <PBPebbleCentralDelegate> {
    PBWatch *_targetWatch;
    
    NSNumber *CARETAKER_KEY_ACCEL_X;
    NSNumber *CARETAKER_KEY_ACCEL_Y;
    NSNumber *CARETAKER_KEY_ACCEL_Z;
}
@end

@implementation AppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        //[self clearFiles];
        
        CARETAKER_KEY_ACCEL_X = [NSNumber numberWithInt:1];//[NSString stringWithFormat:@"%d", 1];//@(1);//[NSNumber numberWithInt:@(1)];
        CARETAKER_KEY_ACCEL_Y = [NSNumber numberWithInt:2];//[NSString stringWithFormat:@"%d", 2];//@(2);//[NSNumber numberWithInt:@(2)];
        CARETAKER_KEY_ACCEL_Z = [NSNumber numberWithInt:3];//[NSString stringWithFormat:@"%d", 3];//@(3);//[NSNumber numberWithInt:@(3)];
        
        accelLoggerPebble = [[AccelerationLogger alloc] initWithFileFlair:@"Pebble"];
    }
    return self;
}

+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(void) clearFiles
{
    NSString *documentsDirectory = [AppDelegate applicationDocumentsDirectory];
    
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                NSLog(@"Error Removing Files...");
            }
        }
    } else {
        // Error handling
        NSLog(@"Error Removing Files...");
    }
}

- (void)setTargetWatch:(PBWatch*)watch {
    NSLog(@"Setting target watch");
    _targetWatch = watch;
    
    // NOTE:
    // For demonstration purposes, we start communicating with the watch immediately upon connection,
    // because we are calling -appMessagesGetIsSupported: here, which implicitely opens the communication session.
    // Real world apps should communicate only if the user is actively using the app, because there
    // is one communication session that is shared between all 3rd party iOS apps.
    
    // Test if the Pebble's firmware supports AppMessages / Weather:
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            // Configure our communications channel to target the weather app:
            // See demos/feature_app_messages/weather.c in the native watch app SDK for the same definition on the watch's end:
            
            
            uuid_t myAppUUIDbytes;
            NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"0385c897-0eb3-4ed8-9162-f68fa6d7a29b"];
            [myAppUUID getUUIDBytes:myAppUUIDbytes];
            
            [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
            
            NSString *message = [NSString stringWithFormat:@"Yay! %@ supports AppMessages :D", [watch name]];
            [[[UIAlertView alloc] initWithTitle:@"Connected!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            
            NSString *message = [NSString stringWithFormat:@"Blegh... %@ does NOT support AppMessages :'(", [watch name]];
            [[[UIAlertView alloc] initWithTitle:@"Connected..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    // Initialize with the last connected watch:
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
    [_targetWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
        [_targetWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
            QuietLog(@"Received Message: %@", update);
            
            float x = (float)([[update objectForKey:CARETAKER_KEY_ACCEL_X] intValue]) / 1000.0f;
            float y = (float)([[update objectForKey:CARETAKER_KEY_ACCEL_Y] intValue]) / 1000.0f;
            float z = (float)([[update objectForKey:CARETAKER_KEY_ACCEL_Z] intValue]) / 1000.0f;

            QuietLog(@"PEBBLE  x=%.2f  y=%.2f  z=%.2f", x, y, z);
            
            [accelLoggerPebble logDataX:x Y:y Z:z];
            return YES;
        }];
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
 *  PBPebbleCentral delegate methods
 */

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Watch did connect");
    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    [[[UIAlertView alloc] initWithTitle:@"Disconnected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (_targetWatch == watch || [watch isEqual:_targetWatch]) {
        [self setTargetWatch:nil];
        [_targetWatch closeSession:nil];
    }
}

- (CMMotionManager *)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    return _motionManager;
}

@end
