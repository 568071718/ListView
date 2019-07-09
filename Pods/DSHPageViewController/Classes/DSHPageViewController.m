//
//  DSHPageViewController.m
//  pageViewController
//
//  Created by 路 on 2019/5/8.
//  Copyright © 2019年 路. All rights reserved.
//

#import "DSHPageViewController.h"

@interface _DSHPageViewControllerCollectionView : UICollectionView
@end
@implementation _DSHPageViewControllerCollectionView
- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource; {
    if ([dataSource isKindOfClass:[DSHPageViewController class]]) {
        [super setDataSource:dataSource];
    }
}
- (void)setDelegate:(id<UICollectionViewDelegate>)delegate; {
    if ([delegate isKindOfClass:[DSHPageViewController class]]) {
        [super setDelegate:delegate];
    }
}
@end

@interface DSHPageViewController () <UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource>

@property (strong ,nonatomic) _DSHPageViewControllerCollectionView *collectionView;
@end

@implementation DSHPageViewController

- (id)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers; {
    return [self initWithViewControllers:viewControllers currentViewControllerIndex:0];
}

- (id)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers currentViewControllerIndex:(NSInteger)currentViewControllerIndex; {
    self = [super init];
    if (self) {
        _viewControllers = viewControllers;
        _currentViewControllerIndex = currentViewControllerIndex;
    } return self;
}

#pragma mark - controller
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _collectionView.frame = self.view.bounds;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentViewControllerIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    
}

#pragma mark - setter
- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex; {
    [self setCurrentViewControllerIndex:currentViewControllerIndex animated:NO];
}

- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex animated:(BOOL)animated; {
    [self setCurrentViewControllerIndex:currentViewControllerIndex animated:animated callDelegate:!animated];
}

- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex animated:(BOOL)animated callDelegate:(BOOL)callDelegate; {
    _currentViewControllerIndex = currentViewControllerIndex;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentViewControllerIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
    if (!animated && callDelegate) {
        if ([_delegate respondsToSelector:@selector(pageViewController:currentViewControllerIndexDidChange:)]) {
            [_delegate pageViewController:self currentViewControllerIndexDidChange:_currentViewControllerIndex];
        }
    }
}

#pragma mark - getter
- (UIScrollView *)scrollView; {
    return self.collectionView;
}

- (_DSHPageViewControllerCollectionView *)collectionView; {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[_DSHPageViewControllerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"page_view_cell"];
    } return _collectionView;
}

#pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView; {
    NSInteger currentViewControllerIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (_currentViewControllerIndex != currentViewControllerIndex) {
        _currentViewControllerIndex = currentViewControllerIndex;
        if ([_delegate respondsToSelector:@selector(pageViewController:currentViewControllerIndexDidChange:)]) {
            [_delegate pageViewController:self currentViewControllerIndexDidChange:_currentViewControllerIndex];
        }
    }
}

#pragma mark - collection view
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    return _viewControllers.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"page_view_cell" forIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    return collectionView.frame.size;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath; {
    UIViewController *viewController = _viewControllers[indexPath.row];
    [self addChildViewController:viewController];
    viewController.view.frame = cell.bounds;
    [cell addSubview:viewController.view];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath; {
    UIViewController *viewController = _viewControllers[indexPath.row];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

@end
