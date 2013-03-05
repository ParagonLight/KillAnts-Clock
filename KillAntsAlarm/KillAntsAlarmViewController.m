//
//  KillAntsAlarmViewController.m
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/13/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import "KillAntsAlarmViewController.h"
#import "ClockView.h"
#import "KillAntsAlarmAppDelegate.h"
#import "KillAntsAlarmOCDModel.h"
#import "RevealController.h"
#import "KillAntsAlarmStartViewController.h"
@interface KillAntsAlarmViewController (){
    CGPoint orignalAntImagePoint;
    CGPoint previousPoint;
    //    CGPoint currentPoint;
    BOOL alarmHandlerTouchedFlag;
    BOOL _ocdOn;
    int isAfternoon;
    int alarmHour;
    int alarmMinute;
    int alarmNewDay;
    int currentHour;
    int currentMinute;
    CGFloat lineOriginY;
    BOOL firstOcdOn;
    CGFloat index;
    CGFloat _deltaAngle;
    CGFloat currentAngle;
    SystemSoundID shortSound;
    SystemSoundID alarmSound;
    SystemSoundID ocdSound;
    UILocalNotification *localNotif;
    UILocalNotification *invisibleNotiOne;
    UILocalNotification *invisibleNotiTwo;
}

@end


@implementation KillAntsAlarmViewController
@synthesize clockView;
@synthesize container = _container;
@synthesize numberImages = _numberImages;
@synthesize digitalAlarmView = _digitalAlarmView;
@synthesize alarmHandlerImageView = _alarmHandlerImageView;
@synthesize alarmHandler = _alarmHandler;
@synthesize alarmHandlerGray = _alarmHandlerGray;
@synthesize ocdAntImage = _ocdAntImage;
@synthesize ocdBall = _ocdBall;
@synthesize antImage = _antImage;
@synthesize ocdBallImageView = _ocdBallImageView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize antTapGestureRecognizer = _antTapGestureRecognizer;
@synthesize antImageView = _antImageView;
@synthesize player = _player;
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(iPhone5){
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"5beijing.jpg"]];
    }else{
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4beijing.jpg"]];
    }
	// Do any additional setup after loading the view, typically from a nib.
    [self initSound];
    [self initClockView];
    KillAntsAlarmAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *dictionary = [appDelegate getInfoFromFile:@"alarmHandler"];
    NSString *radiansString = [dictionary objectForKey:@"lastPosition"];
    NSString *ocdOnString = [dictionary objectForKey:@"ocdOn"];
    NSString *isAfternoonString = [dictionary objectForKey:@"isAfternoon"];
    if([isAfternoonString isEqualToString:@"YES"])
        isAfternoon = 1;
    else
        isAfternoon = 0;
    if([ocdOnString isEqualToString:@"YES"]){
        _ocdOn = YES;
        firstOcdOn = YES;
    }
    else{
        _ocdOn = NO;
        firstOcdOn = NO;
    }
    if(dictionary != nil && radiansString != nil){
        currentAngle = radiansString.floatValue;
        [self initDigitalAlarmViews];
        [self setDigitalAlarmWithOCDCalibration:[self convertRadiansToTimeWithNoCalibrate:[self calibrateRadians:currentAngle]]];
        [self setAlarmHandlerImage];
        CGAffineTransform newTransform3 = CGAffineTransformRotate(_container.transform, currentAngle + M_PI);
        _container.transform = newTransform3;
        NSString *isGray = [dictionary objectForKey:@"isAlarmHandlerGray"];
        if([isGray isEqualToString:@"NO"]){
            alarmHandlerTouchedFlag = TRUE;
            _digitalAlarmView.alpha = 1;
            _antImageView.alpha = 1;
            _ocdBallImageView.alpha = 1;
            _alarmHandlerImageView.image = _alarmHandler;
        }
    }else{
        [self initDigitalAlarmViews];
        [self setAlarmHandlerImage];
    }
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleALarmHandler:)];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveAlarmHandler:)];
    _antTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnt:)];
    _antTapGestureRecognizer.delegate = self;
    _tapGestureRecognizer.delegate = self;
    _panGestureRecognizer.delegate = self;
    [_antImageView addGestureRecognizer:_antTapGestureRecognizer];
    [_alarmHandlerImageView addGestureRecognizer:_tapGestureRecognizer];
    [_alarmHandlerImageView addGestureRecognizer:_panGestureRecognizer];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [clockView start];
}

-(void)viewWillAppear:(BOOL)animated{
    [clockView updateClock:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [clockView stop];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)initOcdTime{
    CGFloat radians = currentAngle;
    [self initDigitalAlarmViews];
    CGFloat lastTime = [self convertRadiansToTime:radians];
    [self setDigitalAlarmWithOCDCalibration:lastTime];
    [self setAlarmHandlerImage];
}

-(void)tapAnt:(UITapGestureRecognizer *)recognizer{
    _antImageView.userInteractionEnabled = NO;
    if(_ocdOn){
        [self setOcdON:NO];
        [UIView animateWithDuration:1
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _antImageView.image = _antImage;
                             CGRect frame = _ocdBallImageView.frame;
                             frame.origin.y = -20;
                             [_ocdBallImageView setFrame:frame];
//                             _ocdBallImageView.transform = CGAffineTransformMakeTranslation(0, -68);
                         } completion:^(BOOL finished){
                             _ocdBallImageView.hidden = YES;
                             _antImageView.userInteractionEnabled = YES;
                         }];
    }else{
        _ocdBallImageView.hidden = NO;
        [self setOcdON:YES];
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             CGRect frame = _ocdBallImageView.frame;
                             frame.origin.y = lineOriginY - 1;
                             [_ocdBallImageView setFrame:frame];
//                             _ocdBallImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                         } completion:^(BOOL finished){
                             AudioServicesPlaySystemSound(ocdSound);
                             _antImageView.image = _ocdAntImage;
                             _antImageView.userInteractionEnabled = YES;
                         }];
    }
    KillAntsAlarmAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *dictionary = [appDelegate getInfoFromFile:@"alarmHandler"];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    if(_ocdOn)
        [dictionary setObject:@"YES" forKey:@"ocdOn"];
    else
        [dictionary setObject:@"NO" forKey:@"ocdOn"];
    [appDelegate saveInfoToFile:dictionary infoType:@"alarmHandler"];
    
}

-(void)toggleALarmHandler:(UITapGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        if(!alarmHandlerTouchedFlag){
            alarmHandlerTouchedFlag = YES;
            _digitalAlarmView.alpha = 1;
            _antImageView.alpha = 1;
            _ocdBallImageView.alpha = 1;
            _alarmHandlerImageView.image = _alarmHandler;
            [self saveElementsToAlarmHandlerFile:@"NO" forKey:@"isAlarmHandlerGray"];
        }else{
            alarmHandlerTouchedFlag = NO;
            if(_player.playing)
                [_player stop];
            _digitalAlarmView.alpha = 0.3;
            _antImageView.alpha = 0.3;
            _ocdBallImageView.alpha = 0.3;
            _alarmHandlerImageView.image = _alarmHandlerGray;
            [self saveElementsToAlarmHandlerFile:@"YES" forKey:@"isAlarmHandlerGray"];
            if(localNotif){
                [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
                [[UIApplication sharedApplication] cancelLocalNotification:invisibleNotiOne];
                [[UIApplication sharedApplication] cancelLocalNotification:invisibleNotiTwo];
            }
        }
    }
}

-(void)saveElementsToAlarmHandlerFile:(NSString *)value forKey:(NSString *)key{
    KillAntsAlarmAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *dictionary = [appDelegate getInfoFromFile:@"alarmHandler"];
    if(!dictionary)
        dictionary = [[NSMutableDictionary alloc] init];
    if (isAfternoon == 1) {
            [dictionary setObject:@"YES" forKey:@"isAfternoon"];
    }else
            [dictionary setObject:@"NO" forKey:@"isAfternoon"];
    [dictionary setObject:[NSString stringWithFormat:@"%@",value] forKey:key];
    [appDelegate saveInfoToFile:dictionary infoType:@"alarmHandler"];
}

-(void)moveAlarmHandler:(UIPanGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        _deltaAngle = 0;
        previousPoint = [recognizer locationInView:recognizer.view.superview.superview];
        if(_ocdOn && firstOcdOn){
//            CGPoint point = [recognizer locationInView:recognizer.view.superview.superview];
//            CGPoint center = _container.layer.position;
//            CGFloat currentAngle = atan2(point.y - center.y, point.x - center.x);
            index = currentAngle / (M_PI * 2 / 144);
        }
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        if(recognizer.view.tag == ALARMHANDLER_TAG){
            CGFloat radians = atan2(_container.transform.b, _container.transform.a) + M_PI;
//            CGFloat currentTime = [self convertRadiansToTimeWithNoCalibrate:[self calibrateRadians:radians]];
            [self saveElementsToAlarmHandlerFile:[NSString stringWithFormat:@"%f",radians] forKey:@"lastPosition"];
            [self setAlarm:NO];
        }
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        if(recognizer.view.tag == ALARMHANDLER_TAG && alarmHandlerTouchedFlag){
                CGPoint curPoint = [recognizer locationInView:recognizer.view.superview.superview];
                CGPoint center = _container.layer.position;
                float prevAngle = atan2(previousPoint.y - center.y, previousPoint.x - center.x);
                float curAngle= atan2(curPoint.y - center.y, curPoint.x - center.x);
                float angleDifference = curAngle - prevAngle;
                if(_ocdOn){
                    _deltaAngle += angleDifference;
                    if(firstOcdOn){
                        if(_deltaAngle >= ((int)index + 1 - index) * (M_PI * 2 / 144)){
                            firstOcdOn = NO;
                            _deltaAngle = 0;
                            angleDifference = ((int)index + 1 - index) * (M_PI * 2 / 144);
                        }else if(_deltaAngle <= ((int)index - index) * (M_PI * 2 / 144)){
                            angleDifference = ((int)index - index) * (M_PI * 2 / 144);
                            _deltaAngle = 0;
                            firstOcdOn = NO;
                        }else{
                            angleDifference = 0;
                        }
                    }else{
                        if(_deltaAngle > (M_PI * 2 / 144) || _deltaAngle < -(M_PI * 2 / 144)){
                            if (_deltaAngle > 0) {
                                angleDifference = ([self floatToClosestInteger:angleDifference / (M_PI * 2 / 144)]  + 1) * (M_PI * 2 / 144);
                            }else{
                                angleDifference = ([self floatToClosestInteger:angleDifference / (M_PI * 2 / 144)] - 1) * (M_PI * 2 / 144);
                            }
                            _deltaAngle = 0;
                        }else{
                            angleDifference = 0;
                        }
                    }
                }
                if(angleDifference != 0){
                    AudioServicesPlaySystemSound(shortSound);
                    CGAffineTransform newTransform3 = CGAffineTransformRotate(_container.transform, angleDifference);
                    _container.transform = newTransform3;
  
                    currentAngle = atan2(_container.transform.b, _container.transform.a) + M_PI;
//                    NSLog(@"%f,%f",currentAngle, [self calibrateRadians:currentAngle]);
                    CGFloat currentTime = [self convertRadiansToTimeWithNoCalibrate:[self calibrateRadians:currentAngle]];
                    [self setDigitalAlarmWithOCDCalibration:ceil(currentTime)];
                }
            previousPoint = curPoint;
            }
    }
}

-(NSInteger)floatToClosestInteger:(CGFloat)floatNumber{
    NSInteger decimal = floatNumber - (int)floatNumber;
    if(abs(decimal) >= 0.5){
        if(floatNumber > 0)
            return (int)floatNumber + 1;
        else
            return (int)floatNumber - 1;
    }
    else{
        if(floatNumber > 0)
            return (int)floatNumber;
        else
            return (int)floatNumber;
    }
}

-(CGFloat)calibrateRadians:(CGFloat)radians{
    CGFloat currentRadians = radians - M_PI / 4;
    if(currentRadians < 0){
        currentRadians += (2 * M_PI);
    }
    return currentRadians;
}

-(void)initSound{
    //where you are about to add sound
    NSString *shortSoundPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/shortSound.wav"];
    NSURL *shortSoundFilePath = [NSURL fileURLWithPath:shortSoundPath isDirectory:NO];
    
    //Use audio sevices to create the sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)shortSoundFilePath, &shortSound);
    
    NSString *ocdSoundPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/antHit.mp3"];
    NSURL *ocdSoundFilePath = [NSURL fileURLWithPath:ocdSoundPath isDirectory:NO];
    
    //Use audio sevices to create the sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)ocdSoundFilePath, &ocdSound);
    
    
    
    AudioSessionInitialize (NULL, NULL, NULL, NULL);
    AudioSessionSetActive(true);
    
    // Allow playback even if Ring/Silent switch is on mute
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                             sizeof(sessionCategory),&sessionCategory);
    
    NSString * music = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"wav"];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:music] error:NULL];
    _player.delegate = self;
    _player.numberOfLoops = -1;
    
}

-(void)startAlarm{
    if(!_player.playing){
        [_player play];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        KillAntsAlarmStartViewController *antStartViewController = [storyboard instantiateViewControllerWithIdentifier:@"alarmStart"];
        antStartViewController.delegate = self;
        [self presentModalViewController:antStartViewController animated:YES];
    }
}

-(void)cancelAlarmMusic{
    if(_player.playing){
        [_player stop];
        alarmHandlerTouchedFlag = NO;
        _digitalAlarmView.alpha = 0.3;
        _antImageView.alpha = 0.3;
        _ocdBallImageView.alpha = 0.3;
        _alarmHandlerImageView.image = _alarmHandlerGray;
        [self saveElementsToAlarmHandlerFile:@"YES" forKey:@"isAlarmHandlerGray"];
        
    }
}

-(NSDate *)getDate:(NSInteger)newDay hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setDay:[dateComponents day] + newDay];
    [dateComponents setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateComponents setSecond:second];
    return [calendar dateFromComponents:dateComponents];
}

-(void)setAlarm:(BOOL)now{
    NSDate *invisibleNotiTwoDate;
    NSDate *invisibleNotiOneDate;
    NSDate *notificationDate;
    if (now && !_player.playing) {
        return;
    }else if(now && _player.playing){
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
        int minute = [dateComponents minute] + 1;
        int hour = [dateComponents hour];
        notificationDate = [self getDate:0 hour:hour minute:minute second:0];
        invisibleNotiOneDate = [self getDate:0 hour:hour minute:minute second:30];
        invisibleNotiTwoDate = [self getDate:0 hour:hour minute:minute + 1 second:0];
    }else{
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
        int minute = [dateComponents minute];
        int hour = [dateComponents hour];
        
        if(alarmHour >= hour && alarmMinute > minute){
            alarmNewDay = 0;
        }else
            alarmNewDay = 1;
        
        notificationDate = [self getDate:alarmNewDay hour:alarmHour minute:alarmMinute second:0];
        invisibleNotiOneDate = [self getDate:alarmNewDay hour:alarmHour minute:alarmMinute second:30];
        invisibleNotiTwoDate = [self getDate:alarmNewDay hour:alarmHour minute:alarmMinute + 1 second:0];        
    }
    if(!localNotif){
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        localNotif = [[UILocalNotification alloc] init];
        invisibleNotiOne = [[UILocalNotification alloc] init];
        invisibleNotiTwo = [[UILocalNotification alloc] init];
    }else{
        [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
        [[UIApplication sharedApplication] cancelLocalNotification:invisibleNotiOne];
        [[UIApplication sharedApplication] cancelLocalNotification:invisibleNotiTwo];
    }
    [localNotif setFireDate:notificationDate];
    [localNotif setRepeatInterval:0];
    [localNotif setAlertAction:@"Alarm"];
    [localNotif setAlertBody:@"Get UP!"];

    [invisibleNotiOne setFireDate:invisibleNotiOneDate];
    [invisibleNotiOne setRepeatInterval:NSMinuteCalendarUnit];
    [invisibleNotiOne setHasAction:NO];
    
    [invisibleNotiTwo setFireDate:invisibleNotiTwoDate];
    [invisibleNotiTwo setRepeatInterval:NSMinuteCalendarUnit];
    [invisibleNotiTwo setHasAction:NO];
    
    localNotif.soundName = @"29s.caf";
    invisibleNotiOne.soundName = @"29s.caf";
    invisibleNotiTwo.soundName = @"29s.caf";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [[UIApplication sharedApplication] scheduleLocalNotification:invisibleNotiOne];
    [[UIApplication sharedApplication] scheduleLocalNotification:invisibleNotiTwo];
//    [clockView setAlarm:alarmHour minute:alarmMinute];
}

-(void)initClockView{
    clockView = [[ClockView alloc] initWithFrame:CGRectMake(30, 150, 260, 260)];
    clockView.layer.position = CGPointMake(self.view.frame.size.width/2, clockView.frame.size.height/2 + clockView.frame.origin.y);
	[clockView setClockBackgroundImage:[UIImage imageNamed:@"clock.png"].CGImage];
	[clockView setHourHandImage:[UIImage imageNamed:@"hour.png"].CGImage];
	[clockView setMinHandImage:[UIImage imageNamed:@"minute.png"].CGImage];
	[clockView setSecHandImage:[UIImage imageNamed:@"second.png"].CGImage];
    [clockView setAlarmHandler:[UIImage imageNamed:@"alarmHandler.png"].CGImage];
//    clockView.delegate = self;
    [self.view addSubview:clockView];
}

-(void)initDigitalAlarmViews{
    //set lineImage
    UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line.png"]];
    CGRect frame = lineImageView.frame;
    frame.size.width /= 2;
    frame.size.height /= 2;
    frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
    if(iPhone5)
        frame.origin.y = 80;
    else
        frame.origin.y = 70;
    lineImageView.frame = frame;
    [self.view addSubview:lineImageView];
    
    //set digitalAlarm with number images
    NSMutableArray *array = [[NSMutableArray alloc] init];
    frame = CGRectMake(0, 0, 94/2, 121/2);
    for(int i = 0; i < 10; i ++){
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i]];
        [array addObject:image];
    }
    UIImage *pointImage = [UIImage imageNamed:@"point.png"];
    [array addObject:pointImage];
    _digitalAlarmView = [[UIView alloc] init];
    _digitalAlarmView.alpha = 0.3;
    frame.origin = lineImageView.frame.origin;
    frame.origin.x += 100;
    frame.origin.y -= 30;
    frame.size.width = frame.size.width * 4 + pointImage.size.width + 20;
    frame.size.height = 200;
    NSLog(@"%f",frame.size.width);
    [_digitalAlarmView setFrame:frame];
    _numberImages = [[NSArray alloc] initWithArray:array];
    
    //init digitalNumber views
    CGFloat positionValue = 0;
    for(int i = 0; i < 5; i ++){
        //        NSNumber *p = (NSNumber *)[timeArray objectAtIndex:i];
        UIImageView *numberImage;
        if(i == 2){
            numberImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point.png"]];
            frame = numberImage.frame;
            frame.size.width /= 2.3;
            frame.size.height /= 2.3;
            frame.origin.y += 5;
            positionValue -= 6;
        }else{
            numberImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 94/2, 121/2)];
            numberImage.tag = i;
            frame = numberImage.frame;
        }
        frame.origin.x = positionValue;
        [numberImage setFrame:frame];
        positionValue += frame.size.width - 13;
        if(i == 2){
            positionValue -= 6;
        }
        [_digitalAlarmView addSubview:numberImage];
    }
    
    //convert radians to time with "hh:mm" format
    CGFloat defaultPosition = [self convertRadiansToTimeWithNoCalibrate:[self calibrateRadians:M_PI]];
//    CGFloat defaultPosition = [self convertRadiansToTime2:M_PI direction:-1];
    [self setDigitalALarm:defaultPosition];
    
    [self.view addSubview:_digitalAlarmView];
    
    //set antImage
    _ocdAntImage = [UIImage imageNamed:@"antOcd.png"];
    _antImage = [UIImage imageNamed:@"ant.png"];
    _ocdBall = [UIImage imageNamed:@"ocd.png"];
    _ocdBallImageView = [[UIImageView alloc] initWithImage:_ocdBall];
    frame = _ocdBallImageView.frame;
    frame.origin.x = lineImageView.frame.origin.x + 73;
    frame.size.width /= 2;
    frame.size.height /= 2;
    [self.view addSubview:_ocdBallImageView];
    lineOriginY = lineImageView.frame.origin.y;
    if(_ocdOn){
        _antImageView = [[UIImageView alloc] initWithImage:_ocdAntImage];
        frame.origin.y = lineImageView.frame.origin.y - 1;
    }else{
        _antImageView = [[UIImageView alloc] initWithImage:_antImage];
        _ocdBallImageView.hidden = YES;
        frame.origin.y = 0;
    }
    [_ocdBallImageView setFrame:frame];
    
    _antImageView.tag = ANTIMAGE_TAG;
    _antImageView.alpha = 0.3;
    _antImageView.userInteractionEnabled = YES;
    frame = _antImageView.frame;
    frame.origin.y = lineImageView.frame.origin.y - 8;
    frame.origin.x = lineImageView.frame.origin.x + 56;
    frame.size.height /= 2.3;
    frame.size.width /= 2.3;
    [_antImageView setFrame:frame];
    [_antImageView setCenter:CGPointMake(_antImageView.frame.origin.x + _antImageView.frame.size.width/2, _antImageView.frame.origin.y + _antImageView.frame.size.height/2)];
    [_antImageView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    orignalAntImagePoint = _antImageView.center;
    [self.view addSubview:_antImageView];
}

-(void)setDigitalALarm:(CGFloat)time{
    @synchronized(self){
        NSMutableArray *timeArray = [[NSMutableArray alloc] init];
        alarmHour = (int)time / 60;
        alarmMinute = (int)time % 60;
        if(alarmHour > 9){
            [timeArray addObject:[NSNumber numberWithInt: alarmHour / 10]];
            [timeArray addObject:[NSNumber numberWithInt: alarmHour % 10]];
        }else{
            [timeArray addObject:[NSNumber numberWithInt: 0]];
            [timeArray addObject:[NSNumber numberWithInt: alarmHour]];
        }
        [timeArray addObject:[NSNumber numberWithInt:10]];
        if(alarmMinute > 9){
            [timeArray addObject:[NSNumber numberWithInt: alarmMinute / 10]];
            [timeArray addObject:[NSNumber numberWithInt: alarmMinute % 10]];
        }else{
            [timeArray addObject:[NSNumber numberWithInt: 0]];
            [timeArray addObject:[NSNumber numberWithInt: alarmMinute]];
        }
        
        for(int i = 0; i < 5; i ++){
            NSNumber *p = (NSNumber *)[timeArray objectAtIndex:i];
            UIImageView *numberImage = [_digitalAlarmView.subviews objectAtIndex:i];
            numberImage.image =
            [_numberImages objectAtIndex:p.intValue];
        }
    }
}


-(void)setDigitalAlarmWithOCDCalibration:(int)time{
    @synchronized(self){
        int showTime = time;
        if(_ocdOn){
            if (showTime % OCD_INTERVAL != 0) {
                if(showTime % OCD_INTERVAL > OCD_INTERVAL / 2)
                    showTime = (showTime / OCD_INTERVAL + 1) * OCD_INTERVAL;
                else
                    showTime = (showTime / OCD_INTERVAL) * OCD_INTERVAL;
            }
            if(showTime == TOTAL_TIME)
                showTime = 0;
        }
        alarmHour = showTime / 60;
        alarmMinute = showTime % 60;
        if(currentHour == 23 && alarmHour == 0){
            isAfternoon = 0;
        }else if(currentHour == 11 && alarmHour == 0){
            isAfternoon = 1;
        }else if(currentHour == 0 && alarmHour == 11){
            isAfternoon = 1;
        }else if(currentHour == 12 && alarmHour == 11){
            isAfternoon = 0;
        }
        
        if(isAfternoon)
            alarmHour += 12;
        
        NSMutableArray *timeArray = [[NSMutableArray alloc] init];

        if(alarmHour > 9){
            [timeArray addObject:[NSNumber numberWithInt: alarmHour / 10]];
            [timeArray addObject:[NSNumber numberWithInt: alarmHour % 10]];
        }else{
            [timeArray addObject:[NSNumber numberWithInt: 0]];
            [timeArray addObject:[NSNumber numberWithInt: alarmHour]];
        }
        [timeArray addObject:[NSNumber numberWithInt:10]];
        if(alarmMinute > 9){
            [timeArray addObject:[NSNumber numberWithInt: alarmMinute / 10]];
            [timeArray addObject:[NSNumber numberWithInt: alarmMinute % 10]];
        }else{
            [timeArray addObject:[NSNumber numberWithInt: 0]];
            [timeArray addObject:[NSNumber numberWithInt: alarmMinute]];
        }
        
        for(int i = 0; i < 5; i ++){
            NSNumber *p = (NSNumber *)[timeArray objectAtIndex:i];
            UIImageView *numberImage = [_digitalAlarmView.subviews objectAtIndex:i];
            numberImage.image =
            [_numberImages objectAtIndex:p.intValue];
        }
        currentHour = alarmHour;
        currentMinute = alarmMinute;
    }
}


-(float)computeCosine:(CGPoint)point1 point2:(CGPoint)point2{
    float yDistence = point1.y - point2.y;
    float xDistence = point1.x - point2.x;
    return yDistence / sqrt(yDistence * yDistence + xDistence * xDistence);
}
-(CGFloat)convertRadiansToTimeWithNoCalibrate:(CGFloat)radians{
    return radians / (2 * M_PI) * TOTAL_TIME;
}

-(CGFloat)convertRadiansToTime:(CGFloat)radians{
    CGFloat currentTime = radians / (2 * M_PI) * TOTAL_TIME;
    if (currentTime > (TOTAL_TIME - DEFAULT_RADIAN_TIME)) {
        currentTime -= (TOTAL_TIME - DEFAULT_RADIAN_TIME);
    }else{
        currentTime += DEFAULT_RADIAN_TIME;
    }
    if(currentTime > TOTAL_TIME)
        currentTime -= TOTAL_TIME;
    return currentTime;
}

/*
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    touches = [event allTouches];
    UITouch *touch = [[event allTouches] anyObject];
     if(touch.view.tag == ANTIMAGE_TAG){
        CGPoint curPoint = [[[touches allObjects] objectAtIndex:0] locationInView:touch.view.superview];
        CGPoint prevPoint = [[[touches allObjects] objectAtIndex:0] previousLocationInView:touch.view.superview];
        curPoint.x -= orignalAntImagePoint.x;
        prevPoint.x -= orignalAntImagePoint.x;
        curPoint.y = 0;
        if(curPoint.x < MAX_DELTA)
            [self moveAntImage:curPoint animateWithDuration:0.2 antImageView:(UIImageView *)touch.view completion:nil];
        //        if(curPoint.x > MIN_REVEAL_DELTA){
        //            [self revealController];
        //        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    touches = [event allTouches];
    UITouch *touch = [[event allTouches] anyObject];
    if(touch.view.tag == ANTIMAGE_TAG){
        CGPoint curPoint = [[[touches allObjects] objectAtIndex:0] locationInView:touch.view.superview];
        if(curPoint.x - orignalAntImagePoint.x > MIN_REVEAL_DELTA){
            [self revealController];
        }
        [self moveAntImage:CGPointMake(0,0) animateWithDuration:0.5 antImageView:(UIImageView *)touch.view completion:nil];
    }
}
 */

-(void)moveAntImage:(CGPoint)currentPoint animateWithDuration:(CGFloat)duration antImageView:(UIImageView *)antImageView completion:(void (^)(BOOL finished))completion{
    @synchronized(self){
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            antImageView.transform = CGAffineTransformMakeTranslation(currentPoint.x, currentPoint.y);
        } completion:completion];
    }
}

-(void)revealController{
	RevealController *revealController = [self.parentViewController isKindOfClass:[RevealController class]] ? (RevealController *)self.parentViewController : nil;
    [revealController revealControllerFromFrontViewController:0.5];
}

-(void)setOcdON:(BOOL)ocdOn{
    _ocdOn = ocdOn;
    firstOcdOn = _ocdOn;
}


-(void)setAlarmHandlerImage{
    _container = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, clockView.frame.size.height/2 + clockView.frame.origin.y, CONTAINER_WIDTH, CONTAINER_WIDTH)];
    _alarmHandlerGray = [UIImage imageNamed:@"alarmHandlerGray.png"];
    _alarmHandler = [UIImage imageNamed:@"alarmHandler.png"];
    alarmHandlerTouchedFlag = FALSE;
    _alarmHandlerImageView = [[UIImageView alloc] initWithImage:_alarmHandlerGray];
    
    [_alarmHandlerImageView setTag:ALARMHANDLER_TAG];
    CGRect frame = _alarmHandlerImageView.frame;
    frame.origin.y = _container.frame.size.width - frame.size.width/2;
    frame.origin.x = _container.frame.size.height - frame.size.height/2;
    frame.size.height *= ALARMHANDLER_SCALE;
    frame.size.width *= ALARMHANDLER_SCALE;
    [_alarmHandlerImageView setFrame:frame];
    _alarmHandlerImageView.userInteractionEnabled = YES;
    
    [_container addSubview:_alarmHandlerImageView];
//    _container.backgroundColor = [UIColor grayColor];
    _container.layer.anchorPoint = CGPointMake(0, 0);
    _container.layer.position = CGPointMake(self.view.frame.size.width/2, clockView.frame.size.height/2 + clockView.frame.origin.y - 0.5);
    [self.view addSubview:_container];
}

@end
