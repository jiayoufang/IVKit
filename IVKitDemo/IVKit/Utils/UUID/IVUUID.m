//
//  IVUUID.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/4.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVUUID.h"

/**
 使用此类将获取的UUID保存到系统级别 keychain
 */
@interface IVKeyChain : NSObject

/**
 保存数据

 @param data 数据
 @param service 类似于key
 */
+ (void)addData:(id)data service:(NSString *)service;

/**
 根据service获取保存的数据

 @param service service
 @return 数据
 */
+ (id)dataForService:(NSString *)service;

/**
 移除指定service的值

 @param service service
 */
+ (void)removeDataForService:(NSString *)service;

@end

@implementation IVKeyChain

+ (void)addData:(id)data service:(NSString *)service{
    NSMutableDictionary *query = [self keychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef) query);
    [query setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    SecItemAdd((__bridge_retained CFDictionaryRef)query, NULL);
}

+ (id)dataForService:(NSString *)service{
    id ret = nil;
    NSMutableDictionary *query = [self keychainQuery:service];
    //configure the search setting
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [query setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    
    CFDataRef dataRef = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)query, (CFTypeRef  *)&dataRef) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *) dataRef];
        } @catch (NSException *exception) {
            NSLog(@"Inarchive of %@ failed: %@",service,exception);
        } @finally {
            
        }
    }
    return ret;
}

+ (void)removeDataForService:(NSString *)service{
    NSMutableDictionary *query = [self keychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)query);
}

#pragma Private Methods

+ (NSMutableDictionary *)keychainQuery:(NSString *)service{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:(__bridge_transfer id)kSecClassGenericPassword forKey:(__bridge_transfer id) kSecClass];
    [query setObject:(__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge_transfer id)kSecAttrAccessible];
    [query setObject:service forKey:(__bridge_transfer id)kSecAttrService];
    [query setObject:service forKey:(__bridge_transfer id)kSecAttrAccount];
    return query;
}

@end



/**
 IVUUID
 */

@interface IVUUID()

@property (nonatomic,readwrite, copy) NSString *UUIDString;

@end

static NSString *const IVKEY_UUID_IN_KEYCHAIN = @"IVKEY_UUID_IN_KEYCHAIN";

@implementation IVUUID

+ (instancetype)uuid{
    return [[IVUUID alloc]init];
}

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)UUIDString{
    
    NSString *uuidInKeychain =[IVKeyChain dataForService:IVKEY_UUID_IN_KEYCHAIN];
    if (uuidInKeychain) {
        //存在直接返回
        return uuidInKeychain;
    }
    //获取UUID并将其存放在keychain中
    NSString *uuid = [self uuid];
    [IVKeyChain addData:uuid service:IVKEY_UUID_IN_KEYCHAIN];
    return uuid;
}

#pragma mark - Private Methods

- (NSString *)uuid{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

@end
