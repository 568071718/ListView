//
//  XHHeaderView.h
//  listView
//
//  Created by 路 on 2019/7/9.
//  Copyright © 2019年 路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSHListView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XHHeaderView : UIView <DSHListHeaderView>

@property (assign ,nonatomic) CGFloat viewHeight;
@property (assign ,nonatomic) DSHListHeaderViewScaleMode scaleMode;

@property (weak ,nonatomic) IBOutlet UIButton *button1;
@property (weak ,nonatomic) IBOutlet UIButton *button2;
@end

NS_ASSUME_NONNULL_END
