//
//  KillAntsAlarmAppDelegate.h
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/13/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ZERO_X 82.8
#define ZERO_Y 177.3
#define DEFAULT_RADIAN_TIME 272 + 360
#define TOTAL_TIME 720
#define ANTIMAGE_TAG 2
#define ALARMHANDLER_TAG 1
#define MIN_REVEAL_DELTA 100
#define MIN_DELTA 5
#define MAX_DELTA 160
#define INTRO_PAGES 2
#define ANT_NUM 15
#define CONTAINER_WIDTH 145
#define ALARMHANDLER_SCALE 1/2.3
#define OCD_INTERVAL 5

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define TEXT_FONT_SIZE 50
@class RevealController;
@class KillAntsAlarmStartViewController;
@interface KillAntsAlarmAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) RevealController *viewController;
@property (retain, nonatomic) KillAntsAlarmStartViewController *antsStartViewController;
-(NSMutableDictionary *)getInfoFromFile:(NSString *)infoType;
-(void)saveInfoToFile:(NSDictionary *)info infoType:(NSString *)infoType;
@end
