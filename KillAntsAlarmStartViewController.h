//
//  KillAntsAlarmStartViewController.h
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/26/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ant.h"
@protocol CancelAlarmDelegate <NSObject>

-(void)cancelAlarmMusic;

@end

@interface KillAntsAlarmStartViewController : UIViewController<AntDelegate>{
    id <CancelAlarmDelegate> delegate;
}

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) id <CancelAlarmDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *ants;
@property BOOL isStart;
-(void)restartAntsAnimation;
-(void)antStart;
@end
