//
//  KillAntsAlarmAppDelegate.m
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/13/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import "KillAntsAlarmAppDelegate.h"
#import "KillAntsAlarmOCDModel.h"
#import "RevealController.h"
#import "KillAntsAlarmViewController.h"
#import "KillAntsAlarmStartViewController.h"
@implementation KillAntsAlarmAppDelegate

@synthesize viewController = _viewController;
@synthesize antsStartViewController = _antsStartViewController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    UIViewController *root = self.window.rootViewController;
//
    
    NSDictionary *dictionary = [self getInfoFromFile:@"introductionFinished"];
    if(dictionary != nil && [[dictionary objectForKey:@"isInfoFinished"] isEqualToString:@"YES"]){
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        KillAntsAlarmOCDModel *ocdModel = [storyboard instantiateViewControllerWithIdentifier:@"OCDModel"];
        KillAntsAlarmViewController *root = [storyboard instantiateViewControllerWithIdentifier:@"root"];
        
        RevealController *revealController = [[RevealController alloc] initWithFrontViewController:root rearViewController:ocdModel];
//        NSLog(@"%f,%f",revealController.view.frame.origin.y, revealController.view.frame.size.height);
        
        self.viewController = revealController;
        self.window.rootViewController = self.viewController;
        [self.window makeKeyAndVisible];
        
        UILocalNotification * localNotify = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if(localNotify){
            [self cancelLocalNotificationsAndStartAlarm];
        }else{
            NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
            /*
             3 notifications means time of alarm event won't be ready
             2 notifications means time of alarm event hass fired
             */
            if([array count] <= 2 && [array count] > 0){
                [self cancelLocalNotificationsAndStartAlarm];
            }
        }

    }
    
//
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
    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    /*
     3 notifications means time of alarm event won't be ready
     2 notifications means time of alarm event hass fired
     */
    if([array count] <= 2 && [array count] > 0){
        [self cancelLocalNotificationsAndStartAlarm];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (_antsStartViewController) {
        [_antsStartViewController restartAntsAnimation];
    }
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)cancelLocalNotificationsAndStartAlarm{
    KillAntsAlarmViewController *frontViewcontroller = _viewController.frontViewController;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [frontViewcontroller startAlarm];
}

#pragma save and get information
-(NSMutableDictionary *)getInfoFromFile:(NSString *)infoType{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",infoType]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filename];
    if (fileExists) {
        return [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    }
    return nil;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [self cancelLocalNotificationsAndStartAlarm];
}

-(void)saveInfoToFile:(NSDictionary *)info infoType:(NSString *)infoType{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",infoType]];
    if (![info writeToFile:filename atomically:YES]) {
        NSLog(@"error to save %@",infoType);
    }
}

@end
