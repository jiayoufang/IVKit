//
//  IVCalculatorManager.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/4.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVCalculatorManager.h"

@interface IVCalculatorManager()

@property (nonatomic,assign,readwrite) int total;

@end

@implementation IVCalculatorManager

- (IVCalculatorManager *(^)(int))add{
    
    return ^(int a){
        self.total += a;
        return self;
    };
}

@end
