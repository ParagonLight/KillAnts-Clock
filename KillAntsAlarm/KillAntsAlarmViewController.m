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
    BOOL firstOcdOn;
    CGFloat index;
    CGFloat _deltaAngle;
    CGFloat currentAngle;
    SystemSoundID shortSound;
    SystemSoundID alarmSound;
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
@synthesize backgroundImageView = _backgroundImageView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize panGestureRecognizer = _panGestureRecognizer;
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
        [self setDigitalAlarmViaImage:[self convertRadiansToTimeWithNoCalibrate:[self calibrateRadians:currentAngle]]];
        [self setAlarmHandlerImage];
        CGAffineTransform newTransform3 = CGAffineTransformRotate(_container.transform, currentAngle + M_PI);
        _container.transform = newTransform3;
        NSString *isGray = [dictionary objectForKey:@"isAlarmHandlerGray"];
        if([isGray isEqualToString:@"NO"]){
            alarmHandlerTouchedFlag = TRUE;
            _digitalAlarmView.alpha = 1;
            _alarmHandlerImageView.image = _alarmHandler;
        }
    }else{
        [self initDigitalAlarmViews];
        [self setAlarmHandlerImage];
    }
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleALarmHandler:)];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveAlarmHandler:)];
    _tapGestureRecognizer.delegate = self;
    _panGestureRecognizer.delegate = self;
    [_alarmHandlerImageView addGestureRecognizer:_tapGestureRecognizer];
    [_alarmHandlerImageView addGestureRecognizer:_panGestureRecognizer];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [clockView start];
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
    [self setDigitalAlarmViaImage:lastTime];
    [self setAlarmHandlerImage];
}

-(void)toggleALarmHandler:(UITapGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        if(!alarmHandlerTouchedFlag){
            alarmHandlerTouchedFlag = YES;
            _digitalAlarmView.alpha = 1;
            _alarmHandlerImageView.image = _alarmHandler;
            [self saveElementsToAlarmHandlerFile:@"NO" forKey:@"isAlarmHandlerGray"];
        }else{
            alarmHandlerTouchedFlag = NO;
            if(_player.playing)
                [_player stop];
            _digitalAlarmView.alpha = 0.3;
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
            CGFloat currentTime = [self convertRadiansToTimeWithNoCalibrate:[self calibrateRadians:radians]];
            [self saveElementsToAlarmHandlerFile:[NSString stringWithFormat:@"%f",radians] forKey:@"lastPosition"];
            [self setAlarm:currentTime];
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
                    if(_deltaAngle > (M_PI * 2 / 144) || _deltaAngle < -(M_PI * 2 / 144)){
                        if (_deltaAngle > 0) {
                            if(firstOcdOn){
                                angleDifference = ((int)index + 1 - index) * (M_PI * 2 / 144);
                                firstOcdOn = NO;
                            }else
                                angleDifference = (int)(angleDifference / (M_PI * 2 / 144) + 1) * (M_PI * 2 / 144);
                        }else{
                            if(firstOcdOn){
                                angleDifference = ((int)index - index) * (M_PI * 2 / 144);
                                firstOcdOn = NO;
                            }else
                                angleDifference = (int)(angleDifference / (M_PI * 2 / 144) - 1) * (M_PI * 2 / 144);
                        }
                        _deltaAngle = 0;
                    }else{
                        angleDifference = 0;
                    }
                }
                if(angleDifference != 0){
                    AudioServicesPlaySystemSound(shortSound);
                    CGAffineTransform newTransform3 = CGAffineTransformRotate(_container.transform, angleDifference);
                    _container.transform = newTransform3;
  
                    currentAngle = atan2(_container.transform.b, _container.transform.a) + M_PI;
//                    NSLog(@"%f,%f",currentAngle, [self calibrateRadians:currentAngle]);
                    CGFloat currentTime = [self convertRadiansToTimeWithNoCalibrate:[self calibrateRadians:currentAngle]];
                    [self setDigitalAlarmViaImage:currentTime];
                }
            previousPoint = curPoint;
            }
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
    
//    NSString *alarmSoundPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/music.wav"];
//    NSURL *alarmSoundFilePath = [NSURL fileURLWithPath:alarmSoundPath isDirectory:NO];
    
    //Use audio sevices to create the sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)shortSoundFilePath, &shortSound);
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)alarmSoundFilePath, &alarmSound);
    
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

-(void)setAlarm:(CGFloat)dateInFloat{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    int minute = [dateComponents minute];
    int hour = [dateComponents hour];
    
    if(alarmHour >= hour && alarmMinute > minute){
        alarmNewDay = 0;
    }else
        alarmNewDay = 1;
    
    NSDate *notificationDate = [self getDate:alarmNewDay hour:alarmHour minute:alarmMinute second:0];
    NSDate *invisibleNotiOneDate = [self getDate:alarmNewDay hour:alarmHour minute:alarmMinute second:30];
    NSDate *invisibleNotiTwoDate = [self getDate:alarmNewDay hour:alarmHour minute:alarmMinute + 1 second:0];
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
    [clockView setAlarm:alarmHour minute:alarmMinute];
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
    frame.size.width /= 2.3;
    frame.size.height /= 2.3;
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
    frame.origin.x += 85;
    frame.origin.y -= 30;
    frame.size.width = frame.size.width * 4 + pointImage.size.width;
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
            frame.size.width /= 2;
            frame.size.height /= 2;
            frame.origin.y += 5;
        }else{
            numberImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 94/2, 121/2)];
            numberImage.tag = i;
            frame = numberImage.frame;
        }
        frame.origin.x = positionValue;
        [numberImage setFrame:frame];
        positionValue += frame.size.width - 13;
        [_digitalAlarmView addSubview:numberImage];
    }
    
    //convert radians to time with "hh:mm" format
    CGFloat defaultPosition = [self convertRadiansToTimeWithNoCalibrate:[self calibrateRadians:M_PI]];
//    CGFloat defaultPosition = [self convertRadiansToTime2:M_PI direction:-1];
    [self setDigitalALarm:defaultPosition];
    
    [self.view addSubview:_digitalAlarmView];
    
    //set antImage
    _antImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ant.png"]];
    _antImageView.tag = ANTIMAGE_TAG;
    _antImageView.userInteractionEnabled = YES;
    frame = _antImageView.frame;
    frame.origin.y = lineImageView.frame.origin.y - 20;
    frame.origin.x = lineImageView.frame.origin.x + 40;
    frame.size.height /= 2;
    frame.size.width /= 2;
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
//        if(isAfternoon == 1){
//            alarmHour += 12;
//        }
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


-(void)setDigitalAlarmViaImage:(CGFloat)time{
    @synchronized(self){
//        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
//        currentMinute = [dateComponents minute];
//        currentHour = [dateComponents hour];
//        int noon = 0;
//        if (currentHour >= 12) {
//            currentHour -= 12;
//            noon = 1;
//        }
        alarmHour = (int)time / 60;
        alarmMinute = (int)time % 60;
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

//        if(alarmHour * 60 +alarmMinute > currentHour * 60 + currentMinute){
//            if (isAfternoon == 1) {
//                alarmHour += 12;
//            }
//            alarmNewDay = 0;
//        }else if(alarmHour * 60 + alarmMinute <= currentHour * 60 + currentMinute){
//            if (isAfternoon == 0) {
//                alarmHour += 12;
//                alarmNewDay = 0;
//            }else if(isAfternoon == 1){
//                alarmNewDay = 1;
//            }
//        }
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
    _container = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, clockView.frame.size.height/2 + clockView.frame.origin.y, 113, 113)];
    _alarmHandlerGray = [UIImage imageNamed:@"alarmHandlerGray.png"];
    _alarmHandler = [UIImage imageNamed:@"alarmHandler.png"];
    alarmHandlerTouchedFlag = FALSE;
    _alarmHandlerImageView = [[UIImageView alloc] initWithImage:_alarmHandlerGray];
    
    [_alarmHandlerImageView setTag:ALARMHANDLER_TAG];
    CGRect frame = _alarmHandlerImageView.frame;
    frame.origin.y = _container.frame.size.width - frame.size.width/2;
    frame.origin.x = _container.frame.size.height - frame.size.height/2;
    frame.size.height /= 2.3;
    frame.size.width /= 2.3;
    [_alarmHandlerImageView setFrame:frame];
    _alarmHandlerImageView.userInteractionEnabled = YES;
    
    [_container addSubview:_alarmHandlerImageView];
//    _container.backgroundColor = [UIColor grayColor];
    _container.layer.anchorPoint = CGPointMake(0, 0);
    _container.layer.position = CGPointMake(self.view.frame.size.width/2, clockView.frame.size.height/2 + clockView.frame.origin.y - 0.5);
    [self.view addSubview:_container];
}

@end
