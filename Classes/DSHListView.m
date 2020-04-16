//
//  DSHListView.m
//  listView
//
//  Created by 路 on 2019/7/8.
//  Copyright © 2019年 路. All rights reserved.
//

#import "DSHListView.h"

@interface DSHListView () <UIGestureRecognizerDelegate>
{
    CGFloat _page_header_offset_y;
    BOOL _base_scroll_enabled;
}
@property (assign ,nonatomic) CGFloat currentWidth;
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
    _base_scroll_enabled = YES;
    _currentWidth = -1;
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
    
    if (_stationaryHeaderView) {
        _page_header_offset_y = contentSize.height;
        _stationaryHeaderView.dsh_view.frame = CGRectMake(0, _page_header_offset_y, self.frame.size.width, _stationaryHeaderView.viewHeight);
        if (_stationaryHeaderView.dsh_view.superview != self) {
            [self addSubview:_stationaryHeaderView.dsh_view];
        }
        contentSize.height += _stationaryHeaderView.viewHeight;
    }
    
    if (_footerView) {
        CGFloat footerViewHeight = (_stationaryHeaderView && _stationaryHeaderView.offsetY >= 0) ? self.frame.size.height - _stationaryHeaderView.viewHeight - _stationaryHeaderView.offsetY : self.frame.size.height;
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
        CGPoint contentOffset = self.contentOffset;
        
        // 处理手势冲突
        if (_footerView && _scrollView) {
            CGFloat content = self.contentSize.height - self.frame.size.height;
            if (!_base_scroll_enabled) {
                CGPoint baseContentOffset = CGPointMake(0, content);
                if (!CGPointEqualToPoint(baseContentOffset, self.contentOffset)) {
                    self.contentOffset = baseContentOffset;
                }
            } else if (self.contentOffset.y > content) {
                _base_scroll_enabled = NO;
            }
        }
        
        // 实现头部视图缩放效果
        if (_headerView) {
            CGRect frame = _headerView.dsh_view.frame;
            frame.origin.x = 0; frame.origin.y = 0;
            frame.size.width = self.frame.size.width; // 拉满宽度
            if (_headerView.scaleMode == DSHListHeaderViewScaleModeNone) {
                
            } else if (_headerView.scaleMode == DSHListHeaderViewScaleModeH) {
                if (contentOffset.y < 0) {
                    frame.origin.y = contentOffset.y;
                    frame.size.height = _headerView.viewHeight + fabs(contentOffset.y);
                }
            } else if (_headerView.scaleMode == DSHListHeaderViewScaleModeWH) {
                if (contentOffset.y < 0) {
                    frame.origin.y = contentOffset.y;
                    frame.size.height = _headerView.viewHeight + fabs(contentOffset.y);
                    double r = self.frame.size.width / _headerView.viewHeight;
                    frame.size.width = frame.size.height * r;
                    frame.origin.x = - (frame.size.width - self.frame.size.width) * .5; // 居中
                }
            } else if (_headerView.scaleMode == DSHListHeaderViewScaleModeStatic) {
                if (contentOffset.y < 0) {
                    frame.origin.y = contentOffset.y;
                }
            }
            _headerView.dsh_view.frame = frame;
        }
        
        // 悬浮效果
        if (_stationaryHeaderView && _stationaryHeaderView.offsetY >= 0) {
            CGRect frame = _stationaryHeaderView.dsh_view.frame;
            frame.origin.y = _page_header_offset_y;
            _stationaryHeaderView.dsh_view.frame = frame;
        }
        
    } else if (object == _scrollView) {
        if (_base_scroll_enabled) {
            if (_scrollView.contentOffset.y != 0) {
                _scrollView.contentOffset = CGPointZero;
            }
        } else if (_scrollView.contentOffset.y <= 0) {
            _base_scroll_enabled = YES;
        }
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
        if (_base_scroll_enabled) {
            _scrollView.contentOffset = CGPointZero;
        }
    } else {
        _base_scroll_enabled = YES;
    }
}

@end
