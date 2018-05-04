//
//  IVLogRecordManager.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/4.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 用来将所有的log信息和crash信息记录到文件中去，方便之后的bug分析
 */
@interface IVLogRecordManager : NSObject

@property (nonatomic,assign,readonly) BOOL logRecording;///<当前记录log是否可行
@property (nonatomic,assign,readonly) BOOL crashRecording;///<当前记录crash是否可行

@property (nonatomic,strong,readonly) NSString *logFilePath;///<记录log信息的路径
@property (nonatomic,strong,readonly) NSString *crashFilePath;///<记录crash信息的路径

/**
 实例化一个单例

 @return 单例
 */
+ (instancetype)manager;

/**
 开启记录Log信息
 */
- (void)enabledLogRecord;

/**
 开启记录Crash信息
 */
- (void)enabledCrashRecord;

@end
