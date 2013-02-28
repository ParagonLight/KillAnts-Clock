//
//  KillAntsAlarmMoveImageView.m
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/19/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import "KillAntsAlarmMoveImageView.h"

@implementation KillAntsAlarmMoveImageView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    touches = [event allTouches];
    UITouch *touch = [[event allTouches] anyObject];
    if(touch.view.tag == ALARMHANDLER_TAG){
        if(!_alarmHandlerTouchedFlag){
            _alarmHandlerTouchedFlag = TRUE;
            _digitalAlarmView.alpha = 1;
            _alarmHandlerImageView.image = _alarmHandler;
        }
        //        else{
        //            _alarmHandlerTouchedFlag = FALSE;
        //            _alarmHandlerImageView.image = _alarmHandlerGray;
        //        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    touches = [event allTouches];
    UITouch *touch = [[event allTouches] anyObject];
    if(touch.view.tag == ALARMHANDLER_TAG && _alarmHandlerTouchedFlag){
        CGPoint prevPoint = [[[touches allObjects] objectAtIndex:0] previousLocationInView:touch.view.superview];
        CGPoint curPoint = [[[touches allObjects] objectAtIndex:0] locationInView:touch.view.superview];
        
        float prevAngle = atan2(prevPoint.x, prevPoint.y);
        float curAngle= atan2(curPoint.x, curPoint.y);
        float angleDifference = prevAngle - curAngle;
        CGAffineTransform newTransform3 = CGAffineTransformRotate(_container.transform, angleDifference);
        _container.transform = newTransform3;
        CGFloat radians = atan2(_container.transform.b, _container.transform.a) + M_PI;
        CGFloat currentTime = [self convertRadiansToTime:radians];
        [self setDigitalAlarmViaImage:currentTime];
    }else if(touch.view.tag == ANTIMAGE_TAG){
        CGPoint prevPoint = [[[touches allObjects] objectAtIndex:0] previousLocationInView:touch.view.superview];
        CGPoint curPoint = [[[touches allObjects] objectAtIndex:0] locationInView:touch.view];
        CGAffineTransform newTransform = CGAffineTransformMakeTranslation(curPoint.x, 0);
        touch.view.transform = newTransform;
    }
}


@end
