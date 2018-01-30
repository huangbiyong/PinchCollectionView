//
//  ViewController.m
//  捏合
//
//  Created by Admin on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "FileModel.h"
#import "RYPinchCollectionView.h"

@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,RYPinchCollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray *files;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.files = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        FileModel *fileModel = [[FileModel alloc] init];
        fileModel.name = [NSString stringWithFormat:@"%ld",i];
        [self.files addObject:fileModel];
    }
    
    
    CGRect rect = [UIScreen mainScreen].bounds;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 10;
    layout.itemSize = CGSizeMake(150, 250);
    
    
    RYPinchCollectionView *collectionView = [[RYPinchCollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pinchDelegate = self;
    [collectionView setupCollectionPinch];
    [self.view addSubview:collectionView];
    
    [collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
}



#pragma mark - RYPinchCollectionViewDelegate
- (BOOL)collectionView:(RYPinchCollectionView *_Nullable)collectionView canMergeItemFromIndexPath:(NSIndexPath *_Nullable)indexPath toTargetIndexPath:(NSIndexPath *_Nullable)targetIndexPath {
    
//    FileModel *targetFile = self.files[targetIndexPath.item];
//    FileModel *desFile = self.files[indexPath.item];
//
//    // 两个文件夹不能合并
//    if (targetFile.isFolder == YES && desFile.isFolder == YES) {
//        return NO;
//    }
    
    return YES;
}

- (NSIndexPath *)collectionView:(RYPinchCollectionView *)collectionView targetIndexPathFromStartIndexPath:(NSIndexPath *)startIndexPath withEndIndexPath:(NSIndexPath *)endIndexPath {
    return startIndexPath;
}

- (CGSize)collectionView:(RYPinchCollectionView *)collectionView distanceSizeItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(-30, -30);
}

- (void)collectionView:(RYPinchCollectionView *)collectionView willMergeTargetView:(UIView *)targetView targetIndexPath:(NSIndexPath *)targetIndexPath {
    
}

- (void)collectionView:(RYPinchCollectionView *_Nullable)collectionView didMergeItemAtIndexPath:(NSIndexPath *_Nullable)targetIndexPath toIndexPath:(NSIndexPath *_Nullable)indexPath inSection:(NSInteger)section {
    
    FileModel *file = self.files[targetIndexPath.item];
    file.isFolder = YES;
    [self.files removeObjectAtIndex:indexPath.item];
}


#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

#pragma mark - ---------- 允许拖动 ----------
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark - ---------- 更新数据源 ----------
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.files.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FileModel *fileModel = self.files[indexPath.item];
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //cell.hidden = NO;
    
    cell.indexPath = indexPath;
    
    if (!fileModel.isFolder) {
        cell.label.text = fileModel.name;
        cell.label.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.label.text = [NSString stringWithFormat:@"文件夹%@",fileModel.name];
        cell.label.backgroundColor = [UIColor redColor];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"indexPathsForSelectedItems: %@", collectionView.indexPathsForSelectedItems);
}







@end
