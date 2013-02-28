//
//  KillAntsAlarmIntroductionViewController.m
//  KillAntsAlarm
//
//  Created by XU Jingwei on 2/24/13.
//  Copyright (c) 2013 xu jingwei. All rights reserved.
//

#import "KillAntsAlarmIntroductionViewController.h"

@interface KillAntsAlarmIntroductionViewController ()

@end

@implementation KillAntsAlarmIntroductionViewController
@synthesize pageControl = _pageControl;
@synthesize scrollView = _scrollView;
@synthesize introductionPages = _introductionPages;
@synthesize revealController = _revealController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initRevealViewController];
    
    [self initIntroductionPages];
}

-(void)initRevealViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    KillAntsAlarmOCDModel *ocdModel = [storyboard instantiateViewControllerWithIdentifier:@"OCDModel"];
    KillAntsAlarmViewController *root = [storyboard instantiateViewControllerWithIdentifier:@"root"];
    _revealController = [[RevealController alloc] initWithFrontViewController:root rearViewController:ocdModel];
}

-(void)initIntroductionPages{
    
    
//    _introductionPages = [[NSMutableArray alloc] init];
//    for (NSInteger i = 0; i < INTRO_PAGES; ++i) {
//        [_introductionPages addObject:[NSNull null]];
//    }
    //    _pageControl = [[UIPageControl alloc] init];
    //    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = INTRO_PAGES;
    
    _scrollView.frame = [[UIScreen mainScreen] bounds];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * INTRO_PAGES, _scrollView.frame.size.height);
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [_scrollView addGestureRecognizer:singleTap];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *prefix;
    if(iPhone5)
        prefix = @"ip5";
    else
        prefix = @"ip4";
    for (int i = 0; i < INTRO_PAGES; i ++) {
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[UIImage
                                                                       imageNamed:[NSString
                                                                                   stringWithFormat:
                                                                                   @"%@%d.jpg",
                                                                                   prefix,
                                                                                   i
                                                                                   ]]];
        NSLog(@"%@%d.jpg",
              prefix,
              i
              );
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * i;
        newPageView.contentMode = UIViewContentModeScaleToFill;
        newPageView.frame = frame;
        [_scrollView addSubview:newPageView];
        [array addObject:newPageView];
    }
    _introductionPages = [NSArray arrayWithArray:array];
    [self loadVisiblePages];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture{
    CGPoint touchPoint=[gesture locationInView:_scrollView];
    if(touchPoint.x > _scrollView.frame.size.width){
        [self initMainViewController];
    }
}

-(void)initMainViewController{
    [self presentViewController:_revealController animated:NO completion:^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:@"YES" forKey:@"isInfoFinished"];
        KillAntsAlarmAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.viewController = _revealController;
        [appDelegate saveInfoToFile:[NSDictionary dictionaryWithDictionary:dictionary] infoType:@"introductionFinished"];
    }];
}

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = _scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((_scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    if(_scrollView.contentOffset.x > 380){
        [self initMainViewController];        
    }
        
    //DLog(@"%f, %f, %f", self.scrollView.contentOffset.x, pageWidth,self.scrollView.frame.size.width);
    // Update the page control
    _pageControl.currentPage = page;
    
    // Work out which pages we want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<_introductionPages.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= _introductionPages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [_introductionPages objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame;
        //        if(iPhone5)
        //           frame = CGRectMake(0, 2, 320, 273);
        //        else
        frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        NSString *prefix;
        if(iPhone5)
            prefix = @"ip5";
        else
            prefix = @"ip4";
        NSLog(@"%@%d.jpg", prefix,page);
        UIImage *image = [UIImage
                          imageNamed:[NSString
                                      stringWithFormat:
                                      @"%@%d.jpg",
                                      prefix,
                                      page
                                      ]];
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:image];
        newPageView.contentMode = UIViewContentModeScaleToFill;
        newPageView.frame = frame;
        [_scrollView addSubview:newPageView];
        [_introductionPages replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= _introductionPages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [_introductionPages objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [_introductionPages replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    [self loadVisiblePages];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
