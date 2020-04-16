//
//  XHPageViewHeader.h
//  listView
//
//  Created by 路 on 2019/7/9.
//  Copyright © 2019年 路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSHListView.h"

NS_ASSUME_NONNULL_BEGIN

@class XHPageViewHeader;
@protocol XHPageViewHeaderDelegate <NSObject>

- (void)pageViewHeader:(XHPageViewHeader *)pageViewHeader clickedButtonWithButtonIndex:(NSInteger)buttonIndex;
@end

@interface XHPageViewHeader : UIView <DSHListStationaryHeaderView>

@property (assign ,nonatomic) CGFloat viewHeight;
@property (assign ,nonatomic) CGFloat offsetY;

@property (weak ,nonatomic) IBOutlet UIButton *button1;
@property (weak ,nonatomic) IBOutlet UIButton *button2;
@property (weak ,nonatomic) IBOutlet UIButton *button3;

@property (weak ,nonatomic) id <XHPageViewHeaderDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
