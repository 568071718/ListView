//
//  DSHListView.h
//  listView
//
//  Created by 路 on 2019/7/8.
//  Copyright © 2019年 路. All rights reserved.
//  https://github.com/568071718/ListView

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,DSHListHeaderViewScaleMode) {
    DSHListHeaderViewScaleModeNone,
    DSHListHeaderViewScaleModeH,
    DSHListHeaderViewScaleModeWH,
    DSHListHeaderViewScaleModeStatic,
};

@protocol DSHListViewSubview <NSObject>

- (UIView *)dsh_view;
@optional
- (void)dsh_list_view_reloadData:(id)data;
@end

@protocol DSHListHeaderView <DSHListViewSubview>

@property (assign ,nonatomic) CGFloat viewHeight;
@property (assign ,nonatomic) DSHListHeaderViewScaleMode scaleMode;
@end

@protocol DSHListViewCell <DSHListViewSubview>

@property (assign ,nonatomic) CGFloat viewHeight;
@end

@protocol DSHListStationaryHeaderView <DSHListViewSubview>

@property (assign ,nonatomic) CGFloat viewHeight;
@property (assign ,nonatomic) CGFloat offsetY;
@end

@protocol DSHListFooterView <DSHListViewSubview>
@end


@interface DSHListView : UIScrollView

@property (strong ,nonatomic) id <DSHListHeaderView>headerView;
@property (strong ,nonatomic) NSArray <id<DSHListViewCell> >*cells;
@property (strong ,nonatomic) id <DSHListStationaryHeaderView>stationaryHeaderView;
@property (strong ,nonatomic) id <DSHListFooterView>footerView;

- (void)reloadData:(id)data; // 刷新页面数据(对所有子视图发送 dsh_list_view_reloadData: 消息)
- (void)reloadData:(id)data forSubview:(id<DSHListViewSubview>)subview; // 刷新页面数据(对指定子视图发送 dsh_list_view_reloadData: 消息)

/**
 * 如果实现了分页视图并且分页视图内部有 UIScrollView ，需要指向当前正在展示的 UIScrollView 对象，用来处理拖动手势冲突 (切换分页视图时需要对应的更改此属性)
 */
@property (weak ,nonatomic) UIScrollView *scrollView;
@end
