//
//  ClockView.h
//  clock
//
//  Created by Ignacio Enriquez Gutierrez on 1/31/11.
//  Copyright 2011 Nacho4D. All rights reserved.
//  See the file License.txt for copying permission.
//

#import <UIKit/UIKit.h>

//
//@class ClockView;
//
//@protocol ClockViewDelegate <NSObject>
//
//-(void)startAlarm;
//
//@end

@interface ClockView : UIView {
//    id <ClockViewDelegate> _delegate;
	CALayer *containerLayer;
	CALayer *hourHand;
	CALayer *minHand;
	CALayer *secHand;
    CALayer *setAlarmHandler;
	NSTimer *timer;
    int _alarmHour;
    int _alarmMinute;
    SystemSoundID shortSound;
    SystemSoundID alarmSound;
    BOOL alarmPlayed;
    int noon;
}

//@property (nonatomic, assign) id <ClockViewDelegate> delegate;

//basic methods
- (void)start;
- (void)stop;

//customize appearence
-(void)setAlarmHandler:(CGImageRef)image;
- (void)setHourHandImage:(CGImageRef)image;
- (void)setMinHandImage:(CGImageRef)image;
- (void)setSecHandImage:(CGImageRef)image;
- (void)setClockBackgroundImage:(CGImageRef)image;
-(void)setAlarm:(int)hour minute:(int)minute;
-(int)getNoon;
//to customize hands size: adjust following values in .m file
//HOURS_HAND_LENGTH
//MIN_HAND_LENGTH
//SEC_HAND_LENGTH
//HOURS_HAND_WIDTH
//MIN_HAND_WIDTH
//SEC_HAND_WIDTH

@end
