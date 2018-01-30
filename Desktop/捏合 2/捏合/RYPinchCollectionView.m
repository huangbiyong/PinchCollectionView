//
//  RYPinchCollectionView.m
//  捏合
//
//  Created by Admin on 2018/1/29.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "RYPinchCollectionView.h"


@interface RYPinchCollectionView ()

// 手指捏合的两个cell
@property (weak, nonatomic) UICollectionViewCell *targetCell;
@property (weak, nonatomic) UICollectionViewCell *desCell;

//
@property (weak, nonatomic) UIView *targetView;
@property (weak, nonatomic) UIView *desView;

@property (strong, nonatomic) NSIndexPath *targetIndexPath;
@property (strong, nonatomic) NSIndexPath *desIndexPath;


@property (assign, nonatomic) CGPoint targetStartCenter;
@property (assign, nonatomic) CGPoint desStartCenter;

@property (assign, nonatomic) CGSize targetCenterOffset;
@property (assign, nonatomic) CGSize desCenterOffset;


// 是否还在动画状态
@property (assign, nonatomic) BOOL isAnimating;

@end

@implementation RYPinchCollectionView

// 初始化pinch手势
- (void)setupCollectionPinch {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinch];
}

- (void)pinch:(UIPinchGestureRecognizer*)sender {
    //NSLog(@"%ld",sender.state);
    
    if (sender.numberOfTouches == 2) {
        
        switch (sender.state) {
                
            case UIGestureRecognizerStateBegan:
            {
                [self pinchBegan:sender];
            }
                break;
            case UIGestureRecognizerStateChanged:
            {
                [self pinchChange:sender];
            }
                break;
            default: {
              [self cancelMergeFolder];
            }
            break;
        }
    }else {
        [self cancelMergeFolder];
    }
}



#pragma mark - 捏合手势，开始时
- (void)pinchBegan:(UIPinchGestureRecognizer *)sender {
    
    // 相对于self的两个坐标点
    CGPoint point1 = [sender locationOfTouch:0 inView:self];
    CGPoint point2 = [sender locationOfTouch:1 inView:self];
    
    // 相对于window的两个坐标点
    CGPoint windowPoint1 = [sender locationOfTouch:0 inView:nil];
    CGPoint windowPoint2 = [sender locationOfTouch:1 inView:nil];
    
    self.targetIndexPath = [self indexPathForItemAtPoint:point1];
    self.desIndexPath = [self indexPathForItemAtPoint:point2];
    
    // 重新排列
    if (self.targetIndexPath.item > self.desIndexPath.item) {
        NSIndexPath *tempIndexPath = self.targetIndexPath;
        self.targetIndexPath = self.desIndexPath;
        self.desIndexPath = tempIndexPath;
        
        CGPoint tempPoint = point1;
        point1 = point2;
        point2 = tempPoint;
        
        CGPoint tempWindowPoint = windowPoint1;
        windowPoint1 = windowPoint2;
        windowPoint2 = tempWindowPoint;
    }
    
    
    self.targetCell = [self cellForItemAtIndexPath:self.targetIndexPath];
    self.desCell = [self cellForItemAtIndexPath:self.desIndexPath];
    
    
    if (![self validateCells]) {
        return;
    }
    

    self.targetStartCenter = [self convertPoint:self.targetCell.center toView:nil];
    self.desStartCenter = [self convertPoint:self.desCell.center toView:nil];
    
    self.targetCenterOffset = CGSizeMake(windowPoint1.x - self.targetStartCenter.x, windowPoint1.y - self.targetStartCenter.y);
    self.desCenterOffset = CGSizeMake(windowPoint2.x - self.desStartCenter.x, windowPoint2.y - self.desStartCenter.y);
    
    
    self.targetView = [self.targetCell snapshotViewAfterScreenUpdates:NO];
    self.desView = [self.desCell snapshotViewAfterScreenUpdates:NO];
    
    self.targetView.frame = self.targetCell.frame;
    self.desView.frame = self.desCell.frame;
    
    self.targetView.center = self.targetStartCenter;
    self.desView.center = self.desStartCenter;
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.targetView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.desView];
    
    
    self.targetCell.hidden = YES;
    self.desCell.hidden = YES;
}


#pragma mark - 捏合手势，正在滑动
- (void)pinchChange:(UIPinchGestureRecognizer *)sender {
    
    if (![self validateCells] || self.isAnimating) {
        return;
    }
    
    // 相对于window的两个坐标点
    CGPoint windowPoint1 = [sender locationOfTouch:0 inView:nil];
    CGPoint windowPoint2 = [sender locationOfTouch:1 inView:nil];
    
    // 判断哪个坐标是targetView, 哪个是desView
    if (!CGRectContainsPoint(self.targetView.frame, windowPoint1)) {
        CGPoint tempPoint = windowPoint1;
        windowPoint1 = windowPoint2;
        windowPoint2 = tempPoint;
    }
    
    
    // 实时移动
    self.targetView.center = CGPointMake(windowPoint1.x - self.targetCenterOffset.width, windowPoint1.y - self.targetCenterOffset.height);
    self.desView.center = CGPointMake(windowPoint2.x - self.desCenterOffset.width, windowPoint2.y - self.desCenterOffset.height);
    
    
    // 获取两个cell 重叠多少距离，开始合并成一个文件夹
    CGSize distanceSize = CGSizeMake(-30, -30);
    if ([self.pinchDelegate respondsToSelector:@selector(collectionView:distanceSizeItemAtIndexPath:)]) {
        distanceSize = [self.pinchDelegate collectionView:self distanceSizeItemAtIndexPath:self.targetIndexPath];
    }
    
    
    // 开始生成一个文件夹
    CGFloat distanceX = fabs(self.targetView.center.x - self.desView.center.x);
    CGFloat distanceY = fabs(self.targetView.center.y - self.desView.center.y);
    
    if (distanceX < self.targetView.frame.size.width + distanceSize.width && distanceY < self.targetView.frame.size.height + distanceSize.height) {
        [self pinchMergeFolder];
    }
}


#pragma mark - 判断捏合的两个cell，是否有效
- (BOOL)validateCells {
    
    if (!self.targetCell || !self.desCell || self.targetCell == self.desCell) {
        return NO;
    }
    return YES;
}


#pragma mark - 捏合两个cell，合成一个文件夹时调用
- (void)pinchMergeFolder {
    
    // 如果不能合并，手动取消合并
    if (![self canMergeFolder]) {
        [self cancelMergeFolder];
        self.isAnimating = YES;
        return ;
    }
    
    self.isAnimating = YES;
    [self updateTargetCell];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.desView.center = self.targetView.center;
        self.desView.transform = CGAffineTransformMakeScale(0.4, 0.4);
    } completion:^(BOOL finished) {
        [self.desView removeFromSuperview];
        
        // 移动desIndexPath到最后一个cell位置， 实现冒泡效果
        if (self.desIndexPath.item < [self numberOfItemsInSection:0]-1) {
            [self moveItemAtIndexPath:self.desIndexPath toIndexPath:[NSIndexPath indexPathForItem:[self numberOfItemsInSection:0]-1 inSection:0]];
        }
        
        // 将要合并
        if ([self.pinchDelegate respondsToSelector:@selector(collectionView:willMergeTargetView:targetIndexPath:)]) {
            [self.pinchDelegate collectionView:self willMergeTargetView:self.targetView targetIndexPath:self.targetIndexPath];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.targetView.center = self.targetStartCenter;
        } completion:^(BOOL finished) {
            [self.targetView removeFromSuperview];
            
            self.isAnimating = NO;

            if ([self.pinchDelegate respondsToSelector:@selector(collectionView:didMergeItemAtIndexPath:toIndexPath:inSection:)]) {
                [self.pinchDelegate collectionView:self didMergeItemAtIndexPath:self.targetIndexPath toIndexPath:self.desIndexPath inSection:0];
            }
            [self reloadSection];
        }];
    }];
}


#pragma mark - 是否可以合并， 可以自由设置， 默认可以合并
- (BOOL)canMergeFolder {
    
    if ([self.pinchDelegate respondsToSelector:@selector(collectionView:canMergeItemFromIndexPath:toTargetIndexPath:)]) {
        return [self.pinchDelegate collectionView:self canMergeItemFromIndexPath:self.desIndexPath toTargetIndexPath:self.targetIndexPath];
    }
    return YES;
}


#pragma mark - 合并时更新目标cell，view, IndexPath， 获取外界设置的目标cell
- (void)updateTargetCell {
    
    // 默认是合并到第一个cell中
    if ([self.pinchDelegate respondsToSelector:@selector(collectionView:targetIndexPathFromStartIndexPath:withEndIndexPath:)]) {
        
        if (self.targetIndexPath != [self.pinchDelegate collectionView:self targetIndexPathFromStartIndexPath:self.targetIndexPath withEndIndexPath: self.desIndexPath]) {
            
            NSInteger value = self.targetIndexPath.item - self.desIndexPath.item;
            if (value == -1 || value == 1) {
                return ;
            }
            
            UICollectionViewCell *tempCell = self.targetCell;
            self.targetCell = self.desCell;
            self.desCell = tempCell;
            
            UIView *tempView = self.targetView;
            self.targetView = self.desView;
            self.desView = tempView;
            
            NSIndexPath *tempIndexPath = self.targetIndexPath;
            self.targetIndexPath = self.desIndexPath;
            self.desIndexPath = tempIndexPath;
        
            CGPoint tempCenter = self.targetStartCenter;
            self.targetStartCenter = self.desStartCenter;
            self.desStartCenter = tempCenter;
            
            CGSize tempOffset = self.targetCenterOffset;
            self.targetCenterOffset = self.desCenterOffset;
            self.desCenterOffset = tempOffset;
        }
    }
}



#pragma mark - 重载数据
- (void)reloadSection {
    
    [UIView animateWithDuration:0 animations:^{
        [self performBatchUpdates:^{
            [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished) {
            self.targetCell.hidden = NO;
            self.desCell.hidden = NO;
            self.targetCell = nil;
            self.desCell = nil;
        }];
    }];
}


#pragma mark - 取消合并
- (void)cancelMergeFolder {
    
    if (self.isAnimating) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.targetView.center = self.targetStartCenter;
        self.desView.center = self.desStartCenter;
    } completion:^(BOOL finished) {
        [self.targetView removeFromSuperview];
        [self.desView removeFromSuperview];
        
        self.targetCell.hidden = NO;
        self.desCell.hidden = NO;
        
        self.targetCell = nil;
        self.desCell = nil;
        
        self.targetView = nil;
        self.desView = nil;
        
        self.isAnimating = NO;
        
        [self reloadSection];
    }];
    
}






















@end
