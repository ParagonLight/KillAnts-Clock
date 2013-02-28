//
//  CustomUISwtich.m
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/21/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import "CustomUISwtich.h"

@implementation CustomUISwtich

@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize switchButton = _switchButton;
@synthesize switchBody = _switchBody;
@synthesize on = _on;
@synthesize off = _off;
-(id)initWithFrame:(CGRect)frame onImage:(UIImage *)onImage offImage:(UIImage *)offImage switchBody:(UIImage *)switchBody scale:(CGFloat)scale on:(BOOL)on{
    if ((self = [super initWithFrame:frame])) {
        [self customInit:onImage offImage:offImage switchBody:switchBody scale:scale on:on];
    }
    return self;
}

-(void)customInit:(UIImage *)onImage offImage:(UIImage *)offImage switchBody:(UIImage *)switchBody scale:(CGFloat)scale on:(BOOL)on{
    UIImage *scaledSwitch = [self
                            resizeImage:switchBody
                            scaledToSize:CGSizeMake(switchBody.size.width * scale,
                                                    switchBody.size.height * scale)];
    _switchBody = [[UIImageView alloc] initWithImage:scaledSwitch];
    _on = [self
           resizeImage:onImage
           scaledToSize:CGSizeMake(onImage.size.width * scale,
                                   onImage.size.height * scale)];;
    _off = [self
            resizeImage:offImage
            scaledToSize:CGSizeMake(offImage.size.width * scale,
                                    offImage.size.height * scale)];
    _switchButton = [[UIImageView alloc] initWithImage:_off];
    [self addSubview:_switchBody];
    CGRect frame = [_switchButton frame];
    frame.origin = self.bounds.origin;
    [_switchButton setFrame:frame];
    CGPoint center = _switchBody.center;
    [_switchButton setCenter:CGPointMake(_switchButton.center.x - 5, center.y + 1.8)];
    [_switchButton.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    offPosition = _switchButton.center;
    onPosition = CGPointMake(offPosition.x + _switchBody.frame.size.width - _on.size.width/2, offPosition.y);
    if(on){
        switchState = TRUE;
        _switchButton.image = _on;
        _switchButton.transform = CGAffineTransformMakeTranslation(onPosition.x - offPosition.x, 0);
    }
    else{
        switchState = FALSE;
    }
    [self addSubview:_switchButton];
}

-(UIImage *)resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(BOOL)toggle:(UITapGestureRecognizer *)recognizer{
    NSLog(@"Here is the toggle function");
    if(switchState){
        [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _switchButton.transform = CGAffineTransformMakeTranslation(offPosition.x - onPosition.x + 25 , 0);
        } completion:^(BOOL finished){
            if(finished){
                switchState = FALSE;
                _switchButton.image = _off;
            }
        }];
        return FALSE;
    }else{
        [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _switchButton.transform = CGAffineTransformMakeTranslation(onPosition.x - offPosition.x, 0);
        } completion:^(BOOL finished){
            if(finished){
                switchState = TRUE;
               _switchButton.image = _on;
            }
        }];
        return TRUE;
    }
}


@end
