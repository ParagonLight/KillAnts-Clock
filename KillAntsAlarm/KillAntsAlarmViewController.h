//
//  KillAntsAlarmViewController.h
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/13/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockView.h"
#import "KillAntsAlarmStartViewController.h"

@interface KillAntsAlarmViewController : UIViewController<AVAudioPlayerDelegate, UIGestureRecognizerDelegate, CancelAlarmDelegate>

@property (retain, nonatomic) IBOutlet ClockView *clockView;
@property (strong, nonatomic) IBOutlet UIImageView *alarmHandlerImageView;
@property (strong, nonatomic) UIImage *alarmHandlerGray;
@property (strong, nonatomic) UIImage *alarmHandler;
@property (strong, nonatomic) UIImage *ocdAntImage;
@property (strong, nonatomic) UIImage *ocdBall;
@property (strong, nonatomic) UIImage *antImage;
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) NSArray *numberImages;
@property (strong, nonatomic) UIImageView *antImageView;
@property (strong, nonatomic) UIImageView *ocdBallImageView;
@property (strong, nonatomic) UIView *digitalAlarmView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *antTapGestureRecognizer;
@property (strong, nonatomic) AVAudioPlayer *player;
-(void)setOcdON:(BOOL)ocdOn;
-(void)startAlarm;
-(void)setAlarm:(BOOL)now;
@end
