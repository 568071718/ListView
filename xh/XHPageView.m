//
//  XHPageView.m
//  listView
//
//  Created by 路 on 2019/7/9.
//  Copyright © 2019年 路. All rights reserved.
//

#import "XHPageView.h"

@implementation XHPageView

- (id)init; {
    self = [super init];
    if (self) {
        
        XHDemoTableViewController *vc1 = [[XHDemoTableViewController alloc] initWithParams:0];
        XHDemoTableViewController *vc2 = [[XHDemoTableViewController alloc] initWithParams:1];
        XHDemoTableViewController *vc3 = [[XHDemoTableViewController alloc] initWithParams:2];
        
        _viewController = [[DSHPageViewController alloc] initWithViewControllers:@[vc1 ,vc2 ,vc3]];
        [self addSubview:_viewController.view];
        
    } return self;
}

- (void)layoutSubviews; {
    [super layoutSubviews];
    _viewController.view.frame = self.bounds;
}

@end
