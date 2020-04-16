//
//  ViewController.m
//  listView
//
//  Created by 路 on 2019/7/8.
//  Copyright © 2019年 路. All rights reserved.
//

#import "ViewController.h"
#import "XHHeaderView.h"
#import "XHPageViewHeader.h"
#import "XHPageView.h"
#import "XHDemoTableViewController.h"

@interface ViewController () <DSHPageViewControllerDelegate ,XHPageViewHeaderDelegate>

@property (strong ,nonatomic) DSHListView *listView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XHHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"XHHeaderView" owner:nil options:nil].firstObject;
    headerView.viewHeight = 200.f;
    headerView.scaleMode = DSHListHeaderViewScaleModeNone;
    
    XHPageViewHeader *pageViewHeader = [[NSBundle mainBundle] loadNibNamed:@"XHPageViewHeader" owner:nil options:nil].firstObject;
    pageViewHeader.viewHeight = 55.f;
    pageViewHeader.offsetY = 0;
    pageViewHeader.delegate = self;
    
    XHDemoTableViewController *vc1 = [[XHDemoTableViewController alloc] initWithParams:0];
    XHDemoTableViewController *vc2 = [[XHDemoTableViewController alloc] initWithParams:1];
    XHDemoTableViewController *vc3 = [[XHDemoTableViewController alloc] initWithParams:2];
    XHPageView *pageView = [[XHPageView alloc] initWithViewControllers:@[vc1 ,vc2 ,vc3]];
    pageView.delegate = self;
    [self addChildViewController:pageView];
    
    
    CGRect frame = self.view.bounds;
    frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    frame.size.height = frame.size.height - frame.origin.y;
    _listView = [[DSHListView alloc] initWithFrame:frame];
    _listView.headerView = headerView;
    _listView.stationaryHeaderView = pageViewHeader;
    _listView.footerView = pageView;
    [self.view addSubview:_listView];
    
    [self pageViewController:pageView currentViewControllerIndexDidChange:pageView.currentViewControllerIndex];
}

- (void)viewDidLayoutSubviews; {
    [super viewDidLayoutSubviews];
    UIEdgeInsets safeAreaInsets = {0};
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.view.safeAreaInsets;
    } else {
        safeAreaInsets.top = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    CGRect frame = {0};
    frame.origin.x = safeAreaInsets.left;
    frame.origin.y = safeAreaInsets.top;
    frame.size.width = self.view.frame.size.width - safeAreaInsets.left - safeAreaInsets.right;
    frame.size.height = self.view.frame.size.height - safeAreaInsets.top - safeAreaInsets.bottom;
    _listView.frame = frame;
}

#pragma mark -
- (void)pageViewController:(DSHPageViewController *)pageViewController currentViewControllerIndexDidChange:(NSInteger)currentViewControllerIndex; {
    XHDemoTableViewController *vc = (XHDemoTableViewController *)pageViewController.viewControllers[currentViewControllerIndex];
    if ([vc isKindOfClass:[XHDemoTableViewController class]]) {
        _listView.scrollView = vc.tableView;
    } else {
        _listView.scrollView = nil;
    }
}

- (void)pageViewHeader:(XHPageViewHeader *)pageViewHeader clickedButtonWithButtonIndex:(NSInteger)buttonIndex; {
    XHPageView *pageView = (XHPageView *)_listView.footerView;
    BOOL aniamtion = labs(buttonIndex - pageView.currentViewControllerIndex) <= 1;
    [pageView setCurrentViewControllerIndex:buttonIndex animated:aniamtion];
}

@end
