//
//  DSHListView.h
//  listView
//
//  Created by 路 on 2019/7/8.
//  Copyright © 2019年 路. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,DSHListHeaderViewScaleMode) {
    DSHListHeaderViewScaleModeNone,
    DSHListHeaderViewScaleModeH,
    DSHListHeaderViewScaleModeWH,
    DSHListHeaderViewScaleModeStatic,
};

@protocol DSHListHeaderView <NSObject>

@property (assign ,nonatomic) CGFloat viewHeight;
@property (assign ,nonatomic) DSHListHeaderViewScaleMode scaleMode;
@end

@protocol DSHListPageViewHeader <NSObject>

@property (assign ,nonatomic) CGFloat viewHeight;
@property (assign ,nonatomic) CGFloat offsetY; // 悬浮距离顶部位置，设置小于 0 关闭悬浮效果
@end

@protocol DSHListViewCell <NSObject>
@property (assign ,nonatomic) CGFloat viewHeight;
@end

@interface DSHListView : UIScrollView

/// 头部视图
@property (strong ,nonatomic) UIView <DSHListHeaderView>*headerView;

/// 其他自定义视图
@property (strong ,nonatomic ,readonly) NSMutableArray <UIView <DSHListViewCell>*>*cells;

/// 分页视图头部视图
@property (strong ,nonatomic) UIView <DSHListPageViewHeader>*pageViewHeader;

/// 分页视图容器
@property (strong ,nonatomic) UIView *pageView;
@property (weak ,nonatomic) UIScrollView *scrollView; // 如果实现了分页视图并且分页视图内部有 UIScrollView ，需要指向当前正在展示的 UIScrollView 对象，用来处理拖动手势冲突 (切换分页视图时需要对应的更改此属性)

/// 重新布局
- (void)reload;
@end
