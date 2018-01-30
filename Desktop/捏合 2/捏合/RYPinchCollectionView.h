//
//  RYCollectionView.h
//  捏合
//
//  Created by Admin on 2018/1/29.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYPinchCollectionView;

@protocol RYPinchCollectionViewDelegate <NSObject>

@optional

/**
 合并到目标哪个IndexPath,  默认合并到第一个IndexPath

 @param collectionView  RYCollectionView
 @param startIndexPath  第一个IndexPath
 @param endIndexPath    第二个IndexPath
 @return                目标IndexPath
 */
- (NSIndexPath *_Nullable)collectionView:(RYPinchCollectionView *_Nullable)collectionView targetIndexPathFromStartIndexPath:(NSIndexPath *_Nullable)startIndexPath withEndIndexPath:(NSIndexPath *_Nullable)endIndexPath;

/**
 是否可以合并， 默认可以合并

 @param collectionView   RYCollectionView
 @param indexPath        源IndexPath
 @param targetIndexPath  目标IndexPath
 @return 是否可以合并
 */
- (BOOL)collectionView:(RYPinchCollectionView *_Nullable)collectionView canMergeItemFromIndexPath:(NSIndexPath *_Nullable)indexPath toTargetIndexPath:(NSIndexPath *_Nullable)targetIndexPath;

/**
 距离目标cell多少时合并， 默认CGSizeMake(-30, -30)

 @param collectionView  RYCollectionView
 @param indexPath       目标IndexPath
 @return 距离目标cell多少时合并
 */
- (CGSize)collectionView:(RYPinchCollectionView *_Nullable)collectionView distanceSizeItemAtIndexPath:(NSIndexPath *_Nullable)indexPath;


/**
 将要合并，调用

 @param collectionView  RYCollectionView
 @param targetView      目标试图
 @param targetIndexPath 目标IndexPath
 */
- (void)collectionView:(RYPinchCollectionView *_Nullable)collectionView willMergeTargetView:(UIView *_Nullable)targetView targetIndexPath:(NSIndexPath *_Nullable)targetIndexPath;


/**
 合并成功后，调用

 @param collectionView   RYCollectionView
 @param targetIndexPath  目标IndexPath
 @param indexPath        源IndexPath
 @param section 合并成功
 */
- (void)collectionView:(RYPinchCollectionView *_Nullable)collectionView didMergeItemAtIndexPath:(NSIndexPath *_Nullable)targetIndexPath toIndexPath:(NSIndexPath *_Nullable)indexPath inSection:(NSInteger)section;

@end

@interface RYPinchCollectionView : UICollectionView

@property (nonatomic, weak, nullable) id <RYPinchCollectionViewDelegate> pinchDelegate;

// 初始化捏合手势
- (void)setupCollectionPinch;

// 重载数据
- (void)reloadSection;

@end





