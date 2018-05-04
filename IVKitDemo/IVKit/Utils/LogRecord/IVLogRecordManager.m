//
//  IVLogRecordManager.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/4.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVLogRecordManager.h"
#import <UIKit/UIKit.h>

@interface IVLogRecordManager()

@property (nonatomic,assign,readwrite) BOOL logRecording;
@property (nonatomic,assign,readwrite) BOOL crashRecording;

@property (nonatomic,strong,readwrite) NSString *logFilePath;
@property (nonatomic,strong,readwrite) NSString *crashFilePath;

@end

@implementation IVLogRecordManager

+ (instancetype)manager{
    static IVLogRecordManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IVLogRecordManager alloc]init];
    });
    return instance;
}

- (id)init{
    self = [super init];
    if (self) {
        self.logRecording = NO;
        self.crashRecording = NO;
    }
    return self;
}

- (void)enabledLogRecord{
    //如果已经连接Xcode调试则不输出到文件
    if (isatty(STDOUT_FILENO)) {

        return;
    }

    //判定如果是模拟器就不输出
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model]hasSuffix:@"Simulator"]) {
        return;
    }
    
    //将log文件输出到文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error = %@",[error localizedDescription]);
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    //每次启动都保存一个新的日志文件中
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    self.logFilePath = logFilePath;
    //将log文件输出到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a++", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a++", stderr);
    //开始记录Log信息
    self.logRecording = YES;
}

- (void)enabledCrashRecord{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}


#pragma mark - Private Methods

void UncaughtExceptionHandler(NSException* exception)
{
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *symbols = [exception callStackSymbols];//异常发生时的调用栈
    NSMutableString *strSymbols = [[NSMutableString alloc]init];//将调用栈平成输出日志的字符串
    for (NSString *str in symbols) {
        [strSymbols appendString:str];
        [strSymbols appendString:@"\r\n"];
    }
    //将crash日志保存到Cache目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error = %@",[error localizedDescription]);
        }
    }
    
    NSString *crashFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@",- %@ ->[Uncaught Exception]\r\nName:%@,Reason:%@\r\n[Fe Symbols Start]\r\n%@[Fe Symbols End]\r\n\r\n",dateStr,name,reason,strSymbols];
    
    [IVLogRecordManager manager].crashFilePath = crashFilePath;
    
    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:crashFilePath]) {
        [crashString writeToFile:crashFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:crashFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}


@end
