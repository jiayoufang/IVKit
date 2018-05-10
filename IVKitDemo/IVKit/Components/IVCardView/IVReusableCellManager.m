//
//  IVReusableCellManager.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/10.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVReusableCellManager.h"

@interface IVReusableCellManager()

@end

@implementation IVReusableCellManager
{
    CFMutableDictionaryRef _dic;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (void)dealloc{
    free(_dic);
}

- (void)push:(IVCardViewCell *)cell{
    NSMutableArray *cells = (NSMutableArray *)CFDictionaryGetValue(_dic, (__bridge const void *)(cell.reuseIdentifier));
    if (!cells) {
        cells = [[NSMutableArray alloc]init];
    }
    [cells addObject:cell];
    CFDictionarySetValue(_dic, (__bridge const void *)(cell.reuseIdentifier), (__bridge const void *)(cells));
}

- (IVCardViewCell *)pop:(NSString *)identifier{
    NSMutableArray *cells = (NSMutableArray *)CFDictionaryGetValue(_dic, (__bridge const void *)(identifier));
    IVCardViewCell *cell = [cells firstObject];
    if (cell) {
        [cells removeObject:cell];
        CFDictionarySetValue(_dic, (__bridge const void *)(identifier), (__bridge const void *)(cells));
    }
    return cell;
}

@end
