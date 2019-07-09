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
    
    XHPageView *pageView = [[XHPageView alloc] init];
    pageView.viewController.delegate = self;
    [self addChildViewController:pageView.viewController];
    
    _listView = [[DSHListView alloc] initWithFrame:self.view.bounds];
    _listView.headerView = headerView;
    _listView.pageViewHeader = pageViewHeader;
    _listView.pageView = pageView;
    [self.view addSubview:_listView];
    
    [self pageViewController:pageView.viewController currentViewControllerIndexDidChange:pageView.viewController.currentViewControllerIndex];
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
    XHPageView *pageView = (XHPageView *)_listView.pageView;
    BOOL aniamtion = labs(buttonIndex - pageView.viewController.currentViewControllerIndex) <= 1;
    [pageView.viewController setCurrentViewControllerIndex:buttonIndex animated:aniamtion];
}

@end
