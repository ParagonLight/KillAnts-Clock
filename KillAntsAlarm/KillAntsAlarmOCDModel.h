//
//  KillAntsAlarmOCDModel.h
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/20/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUISwtich.h"
@interface KillAntsAlarmOCDModel : UIViewController<UIGestureRecognizerDelegate>{
    BOOL ocdOn;
}

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) CustomUISwtich *ocdSwitch;

-(BOOL)getOcdOn;
@end
