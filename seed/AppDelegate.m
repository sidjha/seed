//
//  AppDelegate.m
//  seed
//
//  Created by Sid Jha on 2016-08-07.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([launchOptions objectForKey:@"UIApplicationLaunchOptionsLocationKey"]) {
        NSLog(@"Location key present.");
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"tutorialVC"];
        self.window.rootViewController = viewController;
    } else {
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"rootVC"];
        self.window.rootViewController = viewController;
    }

#if DEVELOPMENT
#define FLURRY_API_TOKEN @"J75YBQWSMGNP3V58SJVQ"
#else
#define FLURRY_API_TOKEN @"S4THBZ8CSSK67Y9BZNT6"
#endif
    [Flurry startSession:FLURRY_API_TOKEN];

    // Get vendor ID and store it locally
    [[NSUserDefaults standardUserDefaults] setObject:[self getVendorID] forKey:@"vendorIDStr"];

    return YES;
}


- (NSString *) getVendorID {

    NSUUID *vendorID = [UIDevice currentDevice].identifierForVendor;

    NSString *vendorIDStr = [vendorID UUIDString];

    return vendorIDStr;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"Will resign active.");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"Did enter background.");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"Will enter foreground.");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"Did become active.");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"Will terminate.");
}

@end
