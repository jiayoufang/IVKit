//
//  IVTimer.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/13.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVTimer.h"

@implementation IVTimer
{
    BOOL _valid;
    NSTimeInterval _timeInterval;
    BOOL _repeats;
    __weak id _target;
    SEL _selector;
    dispatch_source_t _source;
    dispatch_semaphore_t _lock;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:@"IVTimer init error" reason:@"Use the designated initializer to init" userInfo:nil];
    return [self initWithFireTime:0 interval:0 target:self selector:@selector(invalidate) repeats:NO];
}

- (instancetype)initWithFireTime:(NSTimeInterval)start interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeats:(BOOL)repeats{
    self = [super init];
    if (self) {
        _repeats = repeats;
        _timeInterval = interval;
        _valid = YES;
        _target = target;
        _selector = selector;
        
        __weak typeof(self) weakSelf = self;
        _lock = dispatch_semaphore_create(1);
        _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_source, dispatch_time(DISPATCH_TIME_NOW, (start * NSEC_PER_SEC)),(interval * NSEC_PER_SEC) , 0);
        dispatch_source_set_event_handler(_source, ^{
            [weakSelf fire];
        });
    }
    return self;
}

+ (IVTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeats:(BOOL)repeats{
    return [[IVTimer alloc]initWithFireTime:interval interval:interval target:self selector:selector repeats:repeats];
}

- (void)invalidate{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_valid) {
        dispatch_source_cancel(_source);
        _source = NULL;
        _target = nil;
        _valid = NO;
    }
    dispatch_semaphore_signal(_lock);
}

- (void)fire{
    if (!_valid) {
        return;
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id target = _target;
    if (!target) {
        dispatch_semaphore_signal(_lock);
        [self invalidate];
    } else {
        dispatch_semaphore_signal(_lock);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:_selector withObject:self];
#pragma clang diagnostic pop
        if (!_repeats) {
            [self invalidate];
        }
    }
}

- (BOOL)repeats{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    BOOL repeat = _repeats;
    dispatch_semaphore_signal(_lock);
    return repeat;
}

- (NSTimeInterval)timeInterval{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSTimeInterval timeInterval = _timeInterval;
    dispatch_semaphore_signal(_lock);
    return timeInterval;
}

- (BOOL)isValid{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    BOOL valid = _valid;
    dispatch_semaphore_signal(_lock);
    return valid;
}

- (void)dealloc{
    [self invalidate];
}

@end
