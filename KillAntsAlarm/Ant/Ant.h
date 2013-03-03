//
//  Ant.h
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/26/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AntDelegate <NSObject>

-(void)countAliveAnt;

@end

@interface Ant : NSObject<UIGestureRecognizerDelegate>{
    id <AntDelegate> delgeate;
    CGPoint lastPosition;
    CGSize size;
    CGFloat lastAngle;
    CGContextRef context;
    BOOL dead;
}
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) id <AntDelegate> delegate;
@property (nonatomic, strong) UIImageView *antImageView;
@property (nonatomic, strong) UIImage *antDeadImage; 
-(id)initAnt:(NSInteger)antNo;
-(void)animateMethod;

@end
