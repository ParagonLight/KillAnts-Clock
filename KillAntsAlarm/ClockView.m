//
//  ClockView.m
//  clock
//
//  Created by Ignacio Enriquez Gutierrez on 1/31/11.
//  Copyright 2011 Nacho4D. All rights reserved.
//  See the file License.txt for copying permission.
//

#import "ClockView.h"


@implementation ClockView
//@synthesize delegate = _delegate;
#pragma mark - Public Methods

- (void)start
{
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	timer = nil;
}

//customize appearence
-(void)setAlarmHandler:(CGImageRef)image{
		setAlarmHandler.backgroundColor = [UIColor grayColor].CGColor;
        setAlarmHandler.contents = (id)image;
}

- (void)setHourHandImage:(CGImageRef)image
{
	if (image == NULL) {
		hourHand.backgroundColor = [UIColor blackColor].CGColor;
		hourHand.cornerRadius = 3;
	}else{
		hourHand.backgroundColor = [UIColor clearColor].CGColor;
		hourHand.cornerRadius = 0.0;
		
	}
	hourHand.contents = (id)image;
}

- (void)setMinHandImage:(CGImageRef)image
{
	if (image == NULL) {
		minHand.backgroundColor = [UIColor grayColor].CGColor;
	}else{
		minHand.backgroundColor = [UIColor clearColor].CGColor;
	}
	minHand.contents = (id)image;
}

- (void)setSecHandImage:(CGImageRef)image
{
	if (image == NULL) {
		secHand.backgroundColor = [UIColor whiteColor].CGColor;
		secHand.borderWidth = 1.0;
		secHand.borderColor = [UIColor grayColor].CGColor;
	}else{
		secHand.backgroundColor = [UIColor clearColor].CGColor;
		secHand.borderWidth = 0.0;
		secHand.borderColor = [UIColor clearColor].CGColor;
	}
	secHand.contents = (id)image;
}

- (void)setClockBackgroundImage:(CGImageRef)image
{
	if (image == NULL) {
		containerLayer.borderColor = [UIColor blackColor].CGColor;
		containerLayer.borderWidth = 1.0;
		containerLayer.cornerRadius = 5.0;
	}else{
        secHand.backgroundColor = [UIColor clearColor].CGColor;
		containerLayer.borderColor = [UIColor clearColor].CGColor;
		containerLayer.borderWidth = 0.0;
		containerLayer.cornerRadius = 0.0;
	}
	containerLayer.contents = (id)image;
}

#pragma mark - Private Methods

//Default sizes of hands:
//in percentage (0.0 - 1.0)
#define HOURS_HAND_LENGTH 0.65
#define MIN_HAND_LENGTH 0.75
#define SEC_HAND_LENGTH 0.8
//in pixels
#define HOURS_HAND_WIDTH 10
#define MIN_HAND_WIDTH 8
#define SEC_HAND_WIDTH 4

float Degrees2Radians(float degrees) { return degrees * M_PI / 180; }


//-(void)initAVPlayer{
//    alarmPlayed = NO;
//    //where you are about to add sound
//    NSString *shortSoundPath = [[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/shortSound.wav"] autorelease];
//    NSURL *shortSoundFilePath = [NSURL fileURLWithPath:shortSoundPath isDirectory:NO];
//    
//    NSString *alarmSoundPath = [[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/music.wav"] autorelease];
//    NSURL *alarmSoundFilePath = [[NSURL fileURLWithPath:alarmSoundPath isDirectory:NO] autorelease];
//    
//    //Use audio sevices to create the sound
//    AudioServicesCreateSystemSoundID((CFURLRef)shortSoundFilePath, &shortSound);
//    AudioServicesCreateSystemSoundID((CFURLRef)alarmSoundFilePath, &alarmSound);
//}

//timer callback
- (void) updateClock:(NSTimer *)theTimer{
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
	NSInteger seconds = [dateComponents second];
	NSInteger minutes = [dateComponents minute];
	NSInteger hours = [dateComponents hour];
//    if(_alarmHour == hours && _alarmMinute == minutes && !alarmPlayed){
//        alarmPlayed = YES;
////        [self.delegate startAlarm];
//    }
//    if(_alarmHour != hours || _alarmMinute != minutes)alarmPlayed = NO;
	if (hours > 12){//PM
        noon = 1;
        hours -=12;
    }else{
        noon = 0;
    }
	//set angles for each of the hands
	CGFloat secAngle = Degrees2Radians(seconds/60.0*360);
	CGFloat minAngle = Degrees2Radians(minutes/60.0*360);
	CGFloat hourAngle = Degrees2Radians(hours/12.0*360) + minAngle/12.0;
	
	//reflect the rotations + 180 degres since CALayers coordinate system is inverted
	secHand.transform = CATransform3DMakeRotation (secAngle+M_PI, 0, 0, 1);
	minHand.transform = CATransform3DMakeRotation (minAngle+M_PI, 0, 0, 1);
	hourHand.transform = CATransform3DMakeRotation (hourAngle+M_PI, 0, 0, 1);
}

-(int)getNoon{
    return noon;
}

#define ZOOM_IN 0.47

#pragma mark - Overrides

- (void) layoutSubviews
{
	[super layoutSubviews];
    containerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	float length = MIN(self.frame.size.width, self.frame.size.height)/2;
	CGPoint c = CGPointMake(containerLayer.frame.size.width/2, containerLayer.frame.size.height/2);
    hourHand.position = minHand.position = secHand.position = c;
	CGFloat w, h;
	
	if (hourHand.contents == NULL){
		w = HOURS_HAND_WIDTH;
		h = length*HOURS_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((CGImageRef)hourHand.contents) * ZOOM_IN;
		h = CGImageGetHeight((CGImageRef)hourHand.contents) * ZOOM_IN;
	}
	hourHand.bounds = CGRectMake(0,0,w,h);
	
	if (minHand.contents == NULL){
		w = MIN_HAND_WIDTH;
		h = length*MIN_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((CGImageRef)minHand.contents) * ZOOM_IN;
		h = CGImageGetHeight((CGImageRef)minHand.contents) * ZOOM_IN;
	}
	minHand.bounds = CGRectMake(0,0,w,h);
	
	if (secHand.contents == NULL){
		w = SEC_HAND_WIDTH;
		h = length*SEC_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((CGImageRef)secHand.contents) * ZOOM_IN;
		h = CGImageGetHeight((CGImageRef)secHand.contents) * ZOOM_IN;
	}
	secHand.bounds = CGRectMake(0,0,w,h);
    
	hourHand.anchorPoint = CGPointMake(0.5,0.13);
	minHand.anchorPoint = CGPointMake(0.5,0.15);
	secHand.anchorPoint = CGPointMake(0.5,0.21);
	containerLayer.anchorPoint = CGPointMake(0.5, 0.5);
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.layer.backgroundColor = [UIColor clearColor].CGColor;
		containerLayer = [[CALayer layer] retain];
		hourHand = [[CALayer layer] retain];
		minHand = [[CALayer layer] retain];
		secHand = [[CALayer layer] retain];
		//default appearance
		[self setClockBackgroundImage:NULL];
		[self setHourHandImage:NULL];
		[self setMinHandImage:NULL];
		[self setSecHandImage:NULL];
		[self setAlarmHandler:NULL];
		//add all created sublayers
		[containerLayer addSublayer:hourHand];
		[containerLayer addSublayer:minHand];
		[containerLayer addSublayer:secHand];
        [self.layer addSublayer:containerLayer];
        [self updateClock:nil];
	}
    
	return self;
}

-(void)setAlarm:(int)hour minute:(int)minute{
    _alarmHour = hour;
    _alarmMinute = minute;
}

- (void)dealloc
{
	[self stop];
	[hourHand release];
	[minHand release];
	[secHand release];
	[containerLayer release];

	[super dealloc];
}

@end