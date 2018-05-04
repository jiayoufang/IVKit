//
//  IVUUID.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/4.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 此类用来获取设备的UUID
 原理为：
 使用CFUUID获取设备唯一标识，由于每次获取的都不一致，所以将其存放在keychain中，除非设备重置，否则不变
 */
@interface IVUUID : NSObject

/* Return a string description of the UUID, such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F" */
@property (nonatomic,readonly, copy) NSString *UUIDString;

/**
 获取一个实例

 @return 实例对象
 */
+ (instancetype)uuid;


@end
