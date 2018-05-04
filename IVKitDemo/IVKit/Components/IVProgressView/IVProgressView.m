//
//  IVProgressView.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVProgressView.h"

@implementation IVProgressView

- (void)setProgress:(float)progress{
    
    if (progress >= 1.0) {
        progress = 1.0;
    }else if (progress <= 0.0){
        progress = 0.0;
    }
    if (_progress == progress) {
        return;
    }
    _progress = progress;
    //手动调用重绘方法
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat radius = rect.size.width * 0.5;
    CGPoint center = CGPointMake(radius, radius);
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = -M_PI_2 + M_PI * 2 * _progress;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path stroke];
}


@end
