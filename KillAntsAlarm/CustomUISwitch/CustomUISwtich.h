//
//  CustomUISwtich.h
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/21/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUISwtich : UIView{
    CGPoint offPosition;
    CGPoint onPosition;
    BOOL switchState;
}

@property (strong, nonatomic) UIImage *on;
@property (strong, nonatomic) UIImage *off;
@property (strong, nonatomic) UIImageView *switchButton;
@property (strong, nonatomic) UIImageView *switchBody;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

-(id)initWithFrame:(CGRect)frame onImage:(UIImage *)on offImage:(UIImage *)off switchBody:(UIImage *)switchBody scale:(CGFloat)scale on:(BOOL)on;

-(BOOL)toggle:(UITapGestureRecognizer *)recognizer;
@end
