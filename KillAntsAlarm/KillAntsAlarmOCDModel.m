//
//  KillAntsAlarmOCDModel.m
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/20/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import "KillAntsAlarmOCDModel.h"
#import "KillAntsAlarmAppDelegate.h"
@implementation KillAntsAlarmOCDModel

@synthesize backgroundImageView = _backgroundImageView;
@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize ocdSwitch = _ocdSwitch;
-(void)viewDidLoad{
    KillAntsAlarmAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *dictionary = [appDelegate getInfoFromFile:@"alarmHandler"];
    NSString *ocdOnString = [dictionary objectForKey:@"ocdOn"];
    if([ocdOnString isEqualToString:@"YES"])
        ocdOn = TRUE;
    else
        ocdOn = FALSE;
    if(iPhone5){
        _backgroundImageView = [[UIImageView alloc]
                                initWithImage:[UIImage imageNamed:@"5beijing.jpg"]];
    }else{
        _backgroundImageView = [[UIImageView alloc]
                                initWithImage:[UIImage imageNamed:@"4beijing.jpg"]];
    }
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                             initWithTarget:self.parentViewController
                             action:@selector(revealGesture:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    [self initCustomSwitch];
    UIImageView *ocdModel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ocdLabel"]];
    CGRect frame = ocdModel.frame;
    frame.origin.x = _ocdSwitch.frame.origin.x + _ocdSwitch.frame.size.width/2 + 10;
    frame.origin.y = _ocdSwitch.frame.origin.y + 3;
    frame.size.width /= 2;
    frame.size.height /= 2;
    [ocdModel setFrame:frame];
    [self.view addSubview:ocdModel];
}

-(void)initCustomSwitch{
    UIImage *on = [UIImage imageNamed:@"ocdOn.png"];
    UIImage *off = [UIImage imageNamed:@"ocdOff.png"];
    UIImage *switchBody = [UIImage imageNamed:@"ocdSwitch.png"];
    _ocdSwitch = [[CustomUISwtich alloc]
                  initWithFrame:CGRectMake(90, 160, 120, 70)
                  onImage:on
                  offImage:off
                  switchBody:switchBody
                  scale:0.5
                  on:ocdOn];
    [self.view addSubview:_ocdSwitch];
    _ocdSwitch.tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(toggle:)];
    _ocdSwitch.tapGestureRecognizer.delegate = self;
    [_ocdSwitch addGestureRecognizer:_ocdSwitch.tapGestureRecognizer];
}


-(void)toggle:(UITapGestureRecognizer *)recognizer{
    ocdOn = [_ocdSwitch toggle:recognizer];
    KillAntsAlarmAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *dictionary = [appDelegate getInfoFromFile:@"alarmHandler"];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    if(ocdOn)
       [dictionary setObject:@"YES" forKey:@"ocdOn"];
    else
        [dictionary setObject:@"NO" forKey:@"ocdOn"];
    [appDelegate saveInfoToFile:dictionary infoType:@"alarmHandler"];
}

-(BOOL)getOcdOn{
    return ocdOn;
}

@end
