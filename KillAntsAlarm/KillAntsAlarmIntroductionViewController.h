//
//  KillAntsAlarmIntroductionViewController.h
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/24/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KillAntsAlarmAppDelegate.h"
#import "KillAntsAlarmOCDModel.h"
#import "KillAntsAlarmViewController.h"
#import "RevealController.h"
@interface KillAntsAlarmIntroductionViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *introductionPages;
@property (nonatomic, strong) RevealController *revealController;
@end
