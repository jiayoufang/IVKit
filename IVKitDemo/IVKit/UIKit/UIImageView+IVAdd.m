//
//  UIImageView+IVAdd.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "UIImageView+IVAdd.h"

@implementation UIImageView (IVAdd)

- (void)iv_maskImageViewWithCornerRadius:(CGFloat)radius{
    CAShapeLayer *shaper = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    shaper.path = path.CGPath;
    self.layer.mask = shaper;
}

@end
