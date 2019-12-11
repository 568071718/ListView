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
@end

@implementation DSHListView

- (id)init; {
    return [self initWithFrame:CGRectZero];
}

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
    self.alwaysBounceVertical = YES;
    self.showsVerticalScrollIndicator = NO;
    self.panGestureRecognizer.delegate = self;
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc; {
    self.scrollView = nil;
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)reload; {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGSize contentSize = self.bounds.size;
    contentSize.height = 0;
    if (_headerView) {
        _headerView.dsh_view.frame = CGRectMake(0, 0, self.frame.size.width, _headerView.viewHeight);
        [self addSubview:_headerView.dsh_view];
        contentSize.height += _headerView.viewHeight;
    }
    
    for (id<DSHListViewCell> cell in _cells) {
        cell.dsh_view.frame = CGRectMake(0, contentSize.height, self.frame.size.width, cell.viewHeight);
        [self addSubview:cell.dsh_view];
        contentSize.height += cell.viewHeight;
    }
    
    if (_pageViewHeader) {
        _page_header_offset_y = contentSize.height;
        _pageViewHeader.dsh_view.frame = CGRectMake(0, _page_header_offset_y, self.frame.size.width, _pageViewHeader.viewHeight);
        [self addSubview:_pageViewHeader.dsh_view];
        contentSize.height += _pageViewHeader.viewHeight;
    }
    
    if (_pageView) {
        CGFloat pageViewHeight = (_pageViewHeader && _pageViewHeader.offsetY >= 0) ? self.frame.size.height - _pageViewHeader.viewHeight - _pageViewHeader.offsetY : self.frame.size.height;
        _pageView.dsh_view.frame = CGRectMake(0, contentSize.height, self.frame.size.width, pageViewHeight);
        [self addSubview:_pageView.dsh_view];
        contentSize.height += pageViewHeight;
    }
    self.contentSize = contentSize;
    [self bringSubviewToFront:_pageViewHeader.dsh_view];
}

- (void)reloadData:(id)body; {
    [self reloadData:body forSubview:_headerView];
    [self reloadData:body forSubview:_pageViewHeader];
    [self reloadData:body forSubview:_pageView];
    for (id<DSHListViewCell> cell in _cells) {
        [self reloadData:body forSubview:cell];
    }
}

- (void)reloadData:(id)body forSubview:(id<DSHListViewSubview>)subview; {
    if ([subview respondsToSelector:@selector(dsh_list_view_reloadData:)]) {
        [subview dsh_list_view_reloadData:body];
    }
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context; {
    if (object == self) {
        CGPoint contentOffset = self.contentOffset;
        
        // 处理手势冲突
        if (_pageView && _scrollView) {
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
                // h
                if (contentOffset.y < 0) {
                    frame.origin.y = contentOffset.y;
                    frame.size.height = _headerView.viewHeight + fabs(contentOffset.y);
                }
            } else if (_headerView.scaleMode == DSHListHeaderViewScaleModeWH) {
                // w + h
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
        if (_pageViewHeader && _pageViewHeader.offsetY >= 0) {
            CGRect frame = _pageViewHeader.dsh_view.frame;
            frame.origin.y = _page_header_offset_y;
            _pageViewHeader.dsh_view.frame = frame;
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
    _headerView = headerView;
    [self reload];
}

- (void)setPageViewHeader:(UIView<DSHListPageViewHeader> *)pageViewHeader; {
    _pageViewHeader = pageViewHeader;
    [self reload];
}

- (void)setCells:(NSArray<id<DSHListViewCell>> *)cells; {
    _cells = cells;
    [self reload];
}

- (void)setPageView:(id<DSHListPageView>)pageView; {
    _pageView = pageView;
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
