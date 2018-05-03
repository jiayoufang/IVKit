//
//  NSString+IVAdd.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IVAdd)

/*!
 @brief 判断字符串是否是纯汉字
 
 @return YES 是 NO 否
 */
- (BOOL)isChinese;

/*!
 判断是否包含汉字
 
 @return YES 是 NO 否
 */
- (BOOL)includeChinese;

/**
 将汉字转化成拼音

 @param tone 拼音是否有声调
 @return 转化后的拼音字符串
 */
-(NSString*)convertChineseToSpellWithTone:(BOOL)tone;

/**
 翻转字符串
 
 @discussion 暂时只能支持纯字母，汉字如何解决？？？
 @return 翻转之后的字符串
 */
- (NSString *)reverse;

@end
