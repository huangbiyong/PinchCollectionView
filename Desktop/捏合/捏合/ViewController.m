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

@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>

@property (weak, nonatomic) UICollectionView *collectionView;

@property (weak, nonatomic) CollectionViewCell *cell1;
@property (weak, nonatomic) CollectionViewCell *cell2;

@property (strong, nonatomic) NSMutableArray *files;

@property (assign, nonatomic) BOOL isAnimation;

@end

@implementation ViewController {
    UIView *view1;
    UIView *view2;
    
    NSIndexPath *index1;
    NSIndexPath *index2;
    
    CGPoint startPoint1;
    CGPoint startPoint2;
    
    CGSize offset1;
    CGSize offset2;
}

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
    
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
//    collectionView.prefetchDataSource = self;
//    collectionView.prefetchingEnabled = YES;
    [self.view addSubview:collectionView];
    
    [collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self;
    [collectionView addGestureRecognizer:pinch];
    
    self.collectionView = collectionView;
    
}

- (void)pinch:(UIPinchGestureRecognizer*)sender {
    //NSLog(@"%ld",sender.state);
    
    if (sender.numberOfTouches == 2) {
        
        switch (sender.state) {
            
            case UIGestureRecognizerStateBegan:
                {
                    CGPoint point1 = [sender locationOfTouch:0 inView:self.collectionView];
                    CGPoint point2 = [sender locationOfTouch:1 inView:self.collectionView];
                    
                    CGPoint windowPoint1 = [sender locationOfTouch:0 inView:nil];
                    CGPoint windowPoint2 = [sender locationOfTouch:1 inView:nil];
                    
                    index1 = [self.collectionView indexPathForItemAtPoint:point1];
                    index2 = [self.collectionView indexPathForItemAtPoint:point2];
     
                    if (index1.item > index2.item) {
                        NSIndexPath *tempIndexPath = index1;
                        index1 = index2;
                        index2 = tempIndexPath;
                        
                        CGPoint tempPoint = point1;
                        point1 = point2;
                        point2 = tempPoint;
                        
                        CGPoint tempWindowPoint = windowPoint1;
                        windowPoint1 = windowPoint2;
                        windowPoint2 = tempWindowPoint;
                    }
                   
                    self.cell1 = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index1];
                    self.cell2 = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index2];
                    
                    startPoint1 = [self.collectionView convertPoint:_cell1.center toView:nil];
                    startPoint2 = [self.collectionView convertPoint:_cell2.center toView:nil];
                    
                    offset1 = CGSizeMake(windowPoint1.x - startPoint1.x, windowPoint1.y - startPoint1.y);
                    offset2 = CGSizeMake(windowPoint2.x - startPoint2.x, windowPoint2.y - startPoint2.y);
                    
                    if (!self.cell1 || !self.cell2 || self.cell1 == self.cell2) {
                        return;
                    }
                    
                    view1 = [self.cell1 snapshotViewAfterScreenUpdates:NO];
                    view2 = [self.cell2 snapshotViewAfterScreenUpdates:NO];
                    
                    view1.frame = _cell1.frame;
                    view2.frame = _cell2.frame;
                    
                    view1.center = startPoint1;
                    view2.center = startPoint2;
              
                    [view1 setAlpha: 0.8];
                    view2.backgroundColor = [UIColor redColor];
                    
      
                    [[UIApplication sharedApplication].keyWindow addSubview:view1];
                    [[UIApplication sharedApplication].keyWindow addSubview:view2];
                    
        
                    _cell1.hidden = YES;
                    _cell2.hidden = YES;
                }
                break;
            case UIGestureRecognizerStateChanged:
                {
                    if (!self.cell1 || !self.cell2) {
                        return;
                    }
                    
                    if (self.isAnimation) {
                        return;
                    }
                
                    CGPoint point1 = [sender locationOfTouch:0 inView:nil];
                    CGPoint point2 = [sender locationOfTouch:1 inView:nil];
                    
                    if (sqrt(pow(point1.x - view1.center.x , 2 ) + pow(point1.y - view1.center.y , 2)) > sqrt(pow(point2.x - view1.center.x , 2 ) + pow(point2.y - view1.center.y , 2))) {
                        
                        CGPoint tempPoint = point1;
                        point1 = point2;
                        point2 = tempPoint;
                    }
                    
                    view1.center = CGPointMake(point1.x - offset1.width, point1.y - offset1.height);
                    view2.center = CGPointMake(point2.x - offset2.width, point2.y - offset2.height);
                    
                    
                    // 已经重叠
                    if (fabs(view1.center.x - view2.center.x) < view1.frame.size.width - 30 && fabs(view1.center.y - view2.center.y) < view1.frame.size.height - 30) {
 
                        [self pinchItemsEnd];
                        //[self.collectionView endInteractiveMovement];
                    }
                    
                }
                break;
            case UIGestureRecognizerStateEnded:
            {
                [self draItemsCancel];
                //[self.collectionView endInteractiveMovement];
            }
                 break;
                
            case UIGestureRecognizerStateCancelled:
            {
                [self draItemsCancel];
            }
                
                break;

            default: {
                [self.collectionView cancelInteractiveMovement];
                break;
            }
        }
    }else {
        [self draItemsCancel];
    }
    
}

- (void)pinchItemsEnd {

    self.isAnimation = YES;
    //[self.collectionView endInteractiveMovement];
    
    [UIView animateWithDuration:0.4 animations:^{
        view2.center = view1.center;
    } completion:^(BOOL finished) {
        [view2 removeFromSuperview];
        [self.collectionView beginInteractiveMovementForItemAtIndexPath:index2];

        [UIView animateWithDuration:0.3 animations:^{
            view1.center = startPoint1;
            
            [self.collectionView updateInteractiveMovementTargetPosition:CGPointMake(600, 600)];
            
        } completion:^(BOOL finished) {
            [view1 removeFromSuperview];
            
            _cell1.hidden = NO;
            _cell1 = nil;
            
            _cell2.hidden = NO;
            _cell2 = nil;
            
            FileModel *file = self.files[index1.item];
            file.isFolder = YES;

            [self.files removeObjectAtIndex:index2.item];
            
            NSLog(@"item = %ld, section = %ld", index2.item, index2.section);
            
            [self.collectionView reloadData];
            self.isAnimation = NO;
            
            [self.collectionView endInteractiveMovement];
        }];
    }];
}

- (void)draItemsCancel {
    
    if (self.isAnimation) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        view1.center = startPoint1;
        view2.center = startPoint2;
    } completion:^(BOOL finished) {
        [view1 removeFromSuperview];
        [view2 removeFromSuperview];
        
        _cell1.hidden = NO;
        _cell2.hidden = NO;
        
        _cell1 = nil;
        _cell2 = nil;
        
        view1 = nil;
        view2 = nil;
        
        [self.collectionView endInteractiveMovement];
    }];

}



#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

#pragma mark - ---------- 允许拖动 ----------
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark - ---------- 更新数据源 ----------
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
//    //移除数据插入到新的位置
//    id obj = [_dataArray objectAtIndex:sourceIndexPath.row];
//    [_dataArray removeObject:[_dataArray objectAtIndex:sourceIndexPath.row]];
//    [_dataArray insertObject:obj
//                     atIndex:destinationIndexPath.row];
    
//    FileModel *file = self.files[index1.item];
//    file.isFolder = YES;
//
//    [self.files removeObjectAtIndex:index2.item];
//
//    [self.collectionView reloadData];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.files.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FileModel *fileModel = self.files[indexPath.item];
    
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                         forIndexPath:indexPath];
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



////以下方法可以全部注释，注释后失去长按放大效果
//#pragma mark - ---------- 允许长按 ----------
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//#pragma mark - ---------- didHighlight ----------
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
//    [collectionView bringSubviewToFront:selectedCell];
//    [UIView animateWithDuration:0.28 animations:^{
//        selectedCell.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
//    }];
//}
//
//#pragma mark - ---------- didUnhighlight ----------
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
//    [UIView animateWithDuration:0.28 animations:^{
//        selectedCell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//    }];
//}
//
//








@end
