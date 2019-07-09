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
@synthesize cells = _cells;

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
    [_headerView removeFromSuperview];
    [_pageViewHeader removeFromSuperview];
    [_pageView removeFromSuperview];
    [_cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGSize contentSize = self.bounds.size;
    contentSize.height = 0;
    if (_headerView) {
        _headerView.frame = CGRectMake(0, 0, self.frame.size.width, _headerView.viewHeight);
        [self addSubview:_headerView];
        contentSize.height += _headerView.viewHeight;
    }
    
    for (UIView <DSHListViewCell>*cell in _cells) {
        cell.frame = CGRectMake(0, contentSize.height, self.frame.size.width, cell.viewHeight);
        [self addSubview:cell];
        contentSize.height += cell.viewHeight;
    }
    
    if (_pageViewHeader) {
        _page_header_offset_y = contentSize.height;
        _pageViewHeader.frame = CGRectMake(0, _page_header_offset_y, self.frame.size.width, _pageViewHeader.viewHeight);
        [self addSubview:_pageViewHeader];
        contentSize.height += _pageViewHeader.viewHeight;
    }
    
    if (_pageView) {
        CGFloat pageViewHeight = (_pageViewHeader.offsetY >= 0) ? self.frame.size.height - _pageViewHeader.frame.size.height - _pageViewHeader.offsetY : self.frame.size.height;
        _pageView.frame = CGRectMake(0, contentSize.height, self.frame.size.width, pageViewHeight);
        [self addSubview:_pageView];
        contentSize.height += _pageView.frame.size.height;
    }
    self.contentSize = contentSize;
    [self bringSubviewToFront:_pageViewHeader];
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
            CGRect frame = _headerView.frame;
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
            _headerView.frame = frame;
        }
        
        // 悬浮效果
        if (_pageViewHeader && _pageViewHeader.offsetY >= 0) {
            CGRect frame = _pageViewHeader.frame;
            frame.origin.y = _page_header_offset_y;
            _pageViewHeader.frame = frame;
        }
        
    } else if (object == _scrollView) {
        if (_base_scroll_enabled) {
            if (!CGPointEqualToPoint(CGPointZero, _scrollView.contentOffset)) {
                _scrollView.contentOffset = CGPointMake(0, 0);
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
    if (headerView && headerView == _headerView) {
        return;
    }
    if (_headerView) {
        [_headerView removeFromSuperview];
    }
    _headerView = headerView;
    [self reload];
}

- (void)setPageViewHeader:(UIView<DSHListPageViewHeader> *)pageViewHeader {
    if (pageViewHeader && pageViewHeader == _pageViewHeader) {
        return;
    }
    if (_pageViewHeader) {
        [_pageViewHeader removeFromSuperview];
    }
    _pageViewHeader = pageViewHeader;
    [self reload];
}

- (void)setPageView:(UIView *)pageView; {
    if (pageView && pageView == _pageView) {
        return;
    }
    if (_pageView) {
        [_pageView removeFromSuperview];
    }
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

- (NSMutableArray <UIView <DSHListViewCell>*>*)cells; {
    if (!_cells) {
        _cells = [NSMutableArray array];
    } return _cells;
}
@end
