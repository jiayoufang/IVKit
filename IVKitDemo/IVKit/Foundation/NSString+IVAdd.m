//
//  NSString+IVAdd.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "NSString+IVAdd.h"

@implementation NSString (IVAdd)

- (BOOL)isChinese{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@",match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)includeChinese{
    for(int i=0; i< [self length];i++)
    {
        int a =[self characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

-(NSString *)convertChineseToSpellWithTone:(BOOL)tone{
    NSMutableString *spell = [self mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)spell, NULL, kCFStringTransformMandarinLatin, NO);
    //加上下面这一句就没有声调了，不加就有
    if (!tone) {
        CFStringTransform((__bridge CFMutableStringRef)spell, NULL, kCFStringTransformStripCombiningMarks, NO);
    }
    return spell;
}

- (NSString *)reverse{
    const char *str = [self UTF8String];
    NSUInteger length = self.length;
    
    char *pReverse = (char *)malloc(length);
    strcpy(pReverse, str);
    for (int i = 0; i < length/2; i++) {
        char c = pReverse[i];
        pReverse[i] = pReverse[length - i - 1];
        pReverse[length - i - 1] = c;
    }
    NSString *retStr = [NSString stringWithUTF8String:pReverse];
    free(pReverse);
    return retStr;
}

@end
