//
//  KillAntsAlarmMoveImageView.h
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/19/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KillAntsAlarmAppDelegate.h"

@interface KillAntsAlarmMoveImageView : UIImageView{
    CGPoint gestureStartPoint;
    CGPoint currentPoint;
}

@end
