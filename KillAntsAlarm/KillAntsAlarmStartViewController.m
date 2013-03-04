//
//  KillAntsAlarmStartViewController.m
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/26/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import "KillAntsAlarmStartViewController.h"
#import "KillAntsAlarmAppDelegate.h"
@interface KillAntsAlarmStartViewController ()

@end

@implementation KillAntsAlarmStartViewController
@synthesize backgroundImageView = _backgroundImageView;
@synthesize ants = _ants;
@synthesize isStart = _isStart;
@synthesize delegate = _delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [self.view setBackgroundColor:[UIColor greenColor]];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(iPhone5){
        _backgroundImageView.image = [UIImage imageNamed:@"5beijing.jpg"];
    }else{
        _backgroundImageView.image = [UIImage imageNamed:@"4beijing.jpg"];
    }
    _isStart = YES;
    KillAntsAlarmAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.antsStartViewController = self;
    [self initAnts];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)countAliveAnt{
//    NSLog(@"%d", [[self.view subviews] count]);
    if([[self.view subviews] count] <= 1){
        [_delegate cancelAlarmMusic];
        _isStart = NO;
        KillAntsAlarmAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.antsStartViewController = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



-(void)restartAntsAnimation{
    if (_isStart == NO) {
        return;
    }
    for (int i = 0; i < [_ants count]; i ++) {
        Ant *ant = [_ants objectAtIndex:i];
        [ant animateMethod];
    }
}

-(void)initAnts{
    _ants = [[NSMutableArray alloc] init];
    for(int i = 0; i < ANT_NUM; i ++){
        int life;
        if(i % 7 == 6)
            life = 4;
        else
            life = 1;
        Ant *ant = [[Ant alloc] initAnt:i withAntLife:life];
        ant.delegate = self;
        [_ants addObject:ant];
        [ant animateMethod];
        [self.view addSubview:ant.antImageView];
//
//        [antThread start];
    }
}


@end
