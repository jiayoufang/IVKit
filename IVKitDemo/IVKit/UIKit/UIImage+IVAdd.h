//
//  UIImage+IVAdd.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IVAdd)

/**
 处理UIImage对象，给其添加圆角操作

 @param radius 圆角度数
 @return 处理之后的UIImage
 */
- (UIImage *)iv_imageWithCornerRadius:(CGFloat)radius;

@end
