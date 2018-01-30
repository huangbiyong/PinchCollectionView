//
//  CollectionViewCell.h
//  捏合
//
//  Created by Admin on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) NSIndexPath *indexPath;


@end
