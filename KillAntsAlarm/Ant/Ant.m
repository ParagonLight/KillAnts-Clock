//
//  Ant.m
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/26/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import "Ant.h"
#import "KillAntsAlarmAppDelegate.h"
@implementation Ant
@synthesize antImageView = _antImageView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize delegate = _delegate;
@synthesize antDeadImage = _antDeadImage;
static inline double radians (double degrees) {return degrees * M_PI/180;}

-(id)initAnt:(NSInteger)antNo withAntLife:(NSInteger)life{
    self = [super init];
    _life = life;
    NSString *antsHitSoundPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/antsHit.mp3"];
    NSString *antsDieSoundPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/antsDie.mp3"];
    NSURL *antsHitFilePath = [NSURL fileURLWithPath:antsHitSoundPath isDirectory:NO];
    NSURL *antsDieFilePath = [NSURL fileURLWithPath:antsDieSoundPath isDirectory:NO];
    //Use audio sevices to create the sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)antsHitFilePath, &antsHit);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)antsDieFilePath, &antsDie);
    AudioSessionInitialize (NULL, NULL, NULL, NULL);
    AudioSessionSetActive(true);

    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if(life > 1){
        for(int i = 0; i < 9; i ++){
            [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"redAnt%d.png",i]]];
        }
    }else{
        for(int i = 0; i < 9; i ++){
            [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ant%d.png",i]]];
        }
    }
    int randomHeight;
    if (iPhone5) {
        randomHeight = 0 + rand() % (568 - 0);
    }else{
        randomHeight = 0 + rand() % (480 - 0);
    }
    dead = FALSE;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    
    CGRect frame = CGRectMake(screenBound.size.width/2, screenBound.size.height/2, 39, 39);
    size = frame.size;
    _antDeadImage = [UIImage imageNamed:@"antDead.png"];
    NSArray *antAnimationArray = [NSArray arrayWithArray:array];
    _antImageView = [[UIImageView alloc]initWithFrame:frame];
    _antImageView.backgroundColor = [UIColor clearColor];
    _antImageView.tag = antNo;
    _antImageView.animationImages = antAnimationArray;
    _antImageView.userInteractionEnabled = YES;
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnt:)];
    [_antImageView addGestureRecognizer:_tapGestureRecognizer];
//    _antImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    _antImageView.animationDuration=0.15;
    _antImageView.animationRepeatCount=0;
    [_antImageView startAnimating];
    lastAngle = 0;
    return self;
}

-(void)tapAnt:(UITapGestureRecognizer *)recognizer{
    _life--;
    if(_life < 1){
        [_antImageView stopAnimating];
        AudioServicesPlaySystemSound(antsDie);
        dead = TRUE;
        _antImageView.image = _antDeadImage;
        [UIImageView animateWithDuration:1 animations:^{
            _antImageView.alpha = 0;
        } completion:^(BOOL finished){
            [_antImageView removeFromSuperview];
            [_delegate countAliveAnt];
        }];
    }else{
        _antImageView.alpha -= 0.2;
    }
}

-(CGFloat)calibrateRadians:(CGFloat)radians{
    CGFloat currentRadians = radians - M_PI / 4;
    if(currentRadians < 0){
        currentRadians += (2 * M_PI);
    }
    return currentRadians;
}


-(void)animateMethod{
    [UIImageView animateWithDuration:0.1 delay:0.0f options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        @synchronized(self){
            int x;
            CGFloat angle = -45 + rand() % 90;
            int base = 10 - abs(angle)/ 46 * 10;
            x = 10 + abs(rand() % base);
            
            CGAffineTransform newTransform3 = CGAffineTransformRotate(_antImageView.transform, radians(angle));
            newTransform3.tx += x * -sin(radians(lastAngle));
            newTransform3.ty += x * -cos(radians(lastAngle));
            lastAngle += -angle;
            [_antImageView setTransform:newTransform3];
        }
    } completion:^(BOOL finished){
        if (finished && !dead){
            CGPoint point = _antImageView.frame.origin;
            CGRect frame = _antImageView.frame;
            CGFloat height;
            if (iPhone5) {
                height = 568;
            }else
                height = 480;
            
            if(point.x < 0 || point.x + frame.size.width > 320){
                CGFloat deltaX = 30 + rand() % 260 - point.x;
                CGPoint center = CGPointMake(_antImageView.center.x + deltaX,_antImageView.center.y);
                _antImageView.center = center;
                NSLog(@"frame: %@, %@",[NSValue valueWithCGPoint:_antImageView.center],[NSValue valueWithCGPoint:_antImageView.frame.origin]);
            }
            
            if(point.y < 0 || point.y + frame.size.height > height){
                CGFloat deltaY = 30 + rand() % (int)height - 60 - point.y;
                CGPoint center = CGPointMake(_antImageView.center.x,_antImageView.center.y + deltaY);
                _antImageView.center = center;
            }
            [self animateMethod];
        }
    }];
}

-(void)setRedAnt:(NSInteger)life{
    _life = life;
}

@end
