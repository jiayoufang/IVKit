//
//  IVCalculatorManager.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/4.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IVCalculatorManager : NSObject

@property (nonatomic,assign,readonly) int total;

- (IVCalculatorManager *(^)(int a))add;

@end
