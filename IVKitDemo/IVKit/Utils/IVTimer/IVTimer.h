//
//  IVTimer.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/13.
//  Copyright © 2018年 Ivan. All rights reserved.
//
/*
 代码来自YYKit<https://github.com/ibireme/YYKit>，放到这儿只是为了方便自己使用
 */


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 IVTimer is a thread-safe timer based on GCD. It has similar API with `NSTimer`.
 IVTimer object differ from NSTimer in a few ways:
 
 * It use GCD to produce timer tick, and won't be affected by runLoop.
 * It make a weak reference to the target, so it can avoid retain cycles.
 * It always fire on main thread.
 
 */
@interface IVTimer : NSObject

- (instancetype)initWithFireTime:(NSTimeInterval)start interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeats:(BOOL)repeats NS_DESIGNATED_INITIALIZER;

+ (IVTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeats:(BOOL)repeats;

@property (nonatomic,assign,readonly) BOOL repeats;
@property (nonatomic,assign,readonly) NSTimeInterval timeInterval;
@property (nonatomic,assign,readonly,getter=isValid) BOOL valid;

- (void)invalidate;

- (void)fire;

@end

NS_ASSUME_NONNULL_END
