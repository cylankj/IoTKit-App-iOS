//
//  FileManager.h
//  LXYProject
//
//  Created by apple on 15/8/26.
//  Copyright (c) 2015年 liuxinyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginManager.h"

@interface FileManager : NSObject
+(FileManager *)shared;
/**
 *  获取应用沙盒根路径
 */
+(NSString *)dirHome;
/**
 *  获取Documents目录路径
 *
 *  @return Documents目录路径
 */
+(NSString *)dirDoc;
/**
 *  获取Library目录路径
 *
 *  @return Library目录路径
 */
+(NSString *)dirLib;
/**
 *  获取Cache目录路径
 *
 *  @return Cache目录路径
 */
+(NSString *)dirCache;
/**
 *  获取Tmp目录路径
 *
 *  @return Tmp目录路径
 */
+(NSString *)dirTmp;
/**
 *  创建文件夹
 *
 *  @param documentsPath 所在路径
 *  @param dir           文件夹名字
 *
 *  @return 创建结果
 */
+(BOOL)createDir:(NSString *)documentsPath DirStr:(NSString *) dir;
/**
 *  创建文件
 *
 *  @param FileName      文件名
 *  @param documentsPath 创建文件路径
 *
 *  @return 创建结果
 */
+(NSString *)createFile:(NSString *) FileName forPath:(NSString *) documentsPath;
/**
 *  写数据到文件
 *
 *  @param FilePath 文件路径
 *  @param content  写入文件信息
 *
 *  @return 写入结果
 */
+(BOOL)writeFile:(NSString *)FilePath text:(NSString *)content;
/**
 *  读文件数据
 *
 *  @param FilePath 文件路径
 *
 *  @return 文件数据
 */
+(NSString *)readFile:(NSString *)FilePath;
/**
 *  文件属性
 *
 *  @param FilePath 文件路径
 *
 *  @return 属性数组
 */
+(NSArray *)fileAttriutes:(NSString *)FilePath;
/**
 *  删除文件
 *
 *  @param FilePath 文件路径
 *
 *  @return 删除结果
 */
+(BOOL)deleteFile:(NSString *)FilePath;

#pragma mark
#pragma mark 加菲狗 path
+ (NSString *)jfgPano720PhotoDirPath:(NSString *)cid;   // 720全景相机  相册路径
+ (NSString *)jfgLogDirPath;       //  jfg 日志文件 路径
+ (NSString *)jfgUpgradeFilePath:(int)deviceType;   //jfg 升级包文件 路径
@end
