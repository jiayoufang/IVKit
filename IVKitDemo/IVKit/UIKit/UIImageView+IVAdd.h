//
//  UIImageView+IVAdd.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (IVAdd)

/**
 利用添加mask的方式给UIImageView添加圆角

 @param radius 圆角度数
 */
- (void )iv_maskImageViewWithCornerRadius:(CGFloat)radius;

@end
