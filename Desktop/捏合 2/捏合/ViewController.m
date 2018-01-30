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
#import "RYCollectionView.h"

@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,RYCollectionViewDelegate>

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
    
    
    RYCollectionView *collectionView = [[RYCollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pinchDelegate = self;
    [collectionView setupCollectionPinch];
    [self.view addSubview:collectionView];
    
    [collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
}



#pragma mark - RYCollectionViewDelegate
- (BOOL)collectionView:(RYCollectionView *_Nullable)collectionView canMoveItemFromIndexPath:(NSIndexPath *_Nullable)indexPath toTargetIndexPath:(NSIndexPath *_Nullable)targetIndexPath {
    return NO;
}


- (NSIndexPath *)collectionView:(RYCollectionView *)collectionView targetIndexPathFromStartIndexPath:(NSIndexPath *)startIndexPath withEndIndexPath:(NSIndexPath *)endIndexPath {
    return startIndexPath;
}

- (void)collectionView:(RYCollectionView *_Nullable)collectionView didMoveItemAtIndexPath:(NSIndexPath *_Nullable)targetIndexPath toIndexPath:(NSIndexPath *_Nullable)indexPath inSection:(NSInteger)section {
    
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
        cell.label.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
