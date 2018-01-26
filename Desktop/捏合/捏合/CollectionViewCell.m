//
//  CollectionViewCell.m
//  捏合
//
//  Created by Admin on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //UIPanGestureRecognizer *tap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    //tap.maximumNumberOfTouches = 2;
    //[self.label addGestureRecognizer:tap];
}

- (void)click:(UIPanGestureRecognizer*)tap {
    
    NSLog(@"indexPath: %ld", self.indexPath.item);
}

@end
