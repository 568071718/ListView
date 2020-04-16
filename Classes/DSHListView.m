//
//  DSHListView.m
//  listView
//
//  Created by 路 on 2019/7/8.
//  Copyright © 2019年 路. All rights reserved.
//

#import "DSHListView.h"

@interface DSHListView () <UIGestureRecognizerDelegate>

@property (assign ,nonatomic) CGFloat currentWidth; // 记录宽度，只有在宽度改变了之后才重新布局子视图 (防止 layoutSubviews 多次调用)
@property (assign ,nonatomic) CGPoint finalContentOffset;
@property (assign ,nonatomic) CGPoint scrollViewFinalContentOffset;
@property (assign ,nonatomic) BOOL baseScrollEnabled; // 控制当前是否需要处理拖动手势 (改变自身的 contentOffset)
@property (assign ,nonatomic) CGFloat offsetHeight; // 最大偏移高度，当自身偏移量超过这个值之后设置 baseScrollEnabled 为 NO，停止改变自身 contentOffset
@end

@implementation DSHListView

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        [self __setup__];
    } return self;
}
- (void)awakeFromNib; {
    [super awakeFromNib];
    [self __setup__];
}
- (void)__setup__; {
    _baseScrollEnabled = YES;
    _currentWidth = -1;
    _finalContentOffset = CGPointMake(0, 0);
    _scrollViewFinalContentOffset = _finalContentOffset;
    self.alwaysBounceVertical = YES;
    self.showsVerticalScrollIndicator = NO;
    self.panGestureRecognizer.delegate = self;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)dealloc; {
    [self setScrollView:nil];
    [self removeObserver:self forKeyPath:@"contentOffset"];
}
- (void)layoutSubviews; {
    [super layoutSubviews];
    if (_currentWidth != self.frame.size.width) {
        // 重新布局 重置自身 contentSize
        _currentWidth = self.frame.size.width;
        [self reload];
    }
}
- (void)reload; {
    CGSize contentSize = self.bounds.size;
    contentSize.height = 0;
    
    if (_headerView) {
        _headerView.dsh_view.frame = CGRectMake(0, 0, self.frame.size.width, _headerView.viewHeight);
        if (_headerView.dsh_view.superview != self) {
            [self addSubview:_headerView.dsh_view];
        }
        contentSize.height += _headerView.viewHeight;
    }
    
    for (id<DSHListViewCell> cell in _cells) {
        cell.dsh_view.frame = CGRectMake(0, contentSize.height, self.frame.size.width, cell.viewHeight);
        if (cell.dsh_view.superview != self) {
            [self addSubview:cell.dsh_view];
        }
        contentSize.height += cell.viewHeight;
    }
    
    _offsetHeight = contentSize.height;
    if (_stationaryHeaderView) {
        CGFloat y = contentSize.height;
        _offsetHeight = y - _stationaryHeaderView.offsetY;
        _stationaryHeaderView.dsh_view.frame = CGRectMake(0, y, self.frame.size.width, _stationaryHeaderView.viewHeight);
        if (_stationaryHeaderView.dsh_view.superview != self) {
            [self addSubview:_stationaryHeaderView.dsh_view];
        }
        contentSize.height += _stationaryHeaderView.viewHeight;
    }
    
    if (_footerView) {
        CGFloat footerViewHeight = self.frame.size.height - _stationaryHeaderView.viewHeight - _stationaryHeaderView.offsetY;
        _footerView.dsh_view.frame = CGRectMake(0, contentSize.height, self.frame.size.width, footerViewHeight);
        if (_footerView.dsh_view.superview != self) {
            [self addSubview:_footerView.dsh_view];
        }
        contentSize.height += footerViewHeight;
    }
    
    if (_stationaryHeaderView.dsh_view) {
        [self bringSubviewToFront:_stationaryHeaderView.dsh_view];
    }
    self.contentSize = contentSize;
}

- (void)reloadData:(id)data; {
    [self reloadData:data forSubview:_headerView];
    [self reloadData:data forSubview:_stationaryHeaderView];
    [self reloadData:data forSubview:_footerView];
    for (id<DSHListViewCell> cell in _cells) {
        [self reloadData:data forSubview:cell];
    }
}

- (void)reloadData:(id)data forSubview:(id<DSHListViewSubview>)subview; {
    if ([subview respondsToSelector:@selector(dsh_list_view_reloadData:)]) {
        [subview dsh_list_view_reloadData:data];
    }
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context; {
    if (object == self) {
        if (!CGPointEqualToPoint(_finalContentOffset, self.contentOffset)) {
            _finalContentOffset = self.contentOffset;
            [self _selfDidScroll];
        }
    }
    if (object == _scrollView) {
        if (!CGPointEqualToPoint(_scrollViewFinalContentOffset, _scrollView.contentOffset)) {
            _scrollViewFinalContentOffset = _scrollView.contentOffset;
            [self _scrollViewDidScroll];
        }
    }
}
- (void)_selfDidScroll; {
    CGFloat offsetY = self.contentOffset.y;
    // 处理手势冲突
    if (_scrollView) {
        if (offsetY > _offsetHeight) {
            _baseScrollEnabled = NO;
        }
        if (!_baseScrollEnabled) {
            self.contentOffset = CGPointMake(0, _offsetHeight);
        }
    }
    // 实现头部视图缩放效果
    if (_headerView) {
        CGRect frame = _headerView.dsh_view.frame;
        frame.origin.x = 0; frame.origin.y = 0;
        frame.size.width = self.frame.size.width; // 拉满宽度
        if (_headerView.scaleMode == DSHListHeaderViewScaleModeH) {
            if (offsetY < 0) {
                frame.origin.y = offsetY;
                frame.size.height = _headerView.viewHeight + fabs(offsetY);
            }
        } else if (_headerView.scaleMode == DSHListHeaderViewScaleModeWH) {
            if (offsetY < 0) {
                frame.origin.y = offsetY;
                frame.size.height = _headerView.viewHeight + fabs(offsetY);
                double r = self.frame.size.width / _headerView.viewHeight;
                frame.size.width = frame.size.height * r;
                frame.origin.x = - (frame.size.width - self.frame.size.width) * .5; // 居中
            }
        } else if (_headerView.scaleMode == DSHListHeaderViewScaleModeStatic) {
            if (offsetY < 0) {
                frame.origin.y = offsetY;
            }
        }
        _headerView.dsh_view.frame = frame;
    }
}
- (void)_scrollViewDidScroll; {
    if (_baseScrollEnabled) {
        _scrollView.contentOffset = CGPointZero;
    }
    if (_scrollView.contentOffset.y < 0) {
        _scrollView.contentOffset = CGPointZero;
        _baseScrollEnabled = YES;
    }
}

#pragma mark -
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer; {
    return (otherGestureRecognizer.view == _scrollView);
}

#pragma mark -
- (void)setHeaderView:(UIView<DSHListHeaderView> *)headerView; {
    if (_headerView == headerView) {
        return;
    }
    [_headerView.dsh_view removeFromSuperview];
    _headerView = headerView;
    [self reload];
}

- (void)setStationaryHeaderView:(UIView<DSHListStationaryHeaderView> *)stationaryHeaderView; {
    if (_stationaryHeaderView == stationaryHeaderView) {
        return;
    }
    [_stationaryHeaderView.dsh_view removeFromSuperview];
    _stationaryHeaderView = stationaryHeaderView;
    [self reload];
}

- (void)setCells:(NSArray<id<DSHListViewCell>> *)cells; {
    if (_cells == cells) {
        return;
    }
    for (id <DSHListViewCell>cell in _cells) {
        [cell.dsh_view removeFromSuperview];
    }
    _cells = cells;
    [self reload];
}

- (void)setFooterView:(id<DSHListFooterView>)footerView; {
    if (_footerView == footerView) {
        return;
    }
    [_footerView.dsh_view removeFromSuperview];
    _footerView = footerView;
    [self reload];
}

- (void)setScrollView:(UIScrollView *)scrollView; {
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    _scrollView = scrollView;
    if (_scrollView) {
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        if (_baseScrollEnabled) {
            _scrollView.contentOffset = CGPointZero;
        }
    } else {
        _baseScrollEnabled = YES;
    }
}

@end
