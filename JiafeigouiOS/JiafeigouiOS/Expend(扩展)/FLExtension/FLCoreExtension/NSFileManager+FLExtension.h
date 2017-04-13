//
//  NSFileManager+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Directory type enum
 */
typedef NS_ENUM(NSInteger, DirectoryType)
{
    DirectoryTypeMainBundle = 0,
    DirectoryTypeLibrary,
    DirectoryTypeDocuments,
    DirectoryTypeCache
};


@interface NSFileManager (FLExtension)

/**
 *  读取某个文件,返回字符串
 *
 *  @param file 文件名
 *  @param type 文件类型
 *
 *  @return 返回内容是一个字符串
 */
+ (NSString *)readTextFile:(NSString *)file
                    ofType:(NSString *)type;

/**
 *  保存一个数组到本地
 */
+ (BOOL)saveArrayToPath:(DirectoryType)path
           withFilename:(NSString *)fileName
                  array:(NSArray *)array;

/**
 *  读取一个本地数组内容
 */
+ (NSArray *)loadArrayFromPath:(DirectoryType)path
                  withFilename:(NSString *)fileName;


+ (NSString *)getBundlePathForFile:(NSString *)fileName;

/**
 *获取Documents下文件路径
 */
+ (NSString *)getDocumentsDirectoryForFile:(NSString *)fileName;

+ (NSString *)getLibraryDirectoryForFile:(NSString *)fileName;

+ (NSString *)getCacheDirectoryForFile:(NSString *)fileName;

/**
 *  删除某个文件
 */
+ (BOOL)deleteFile:(NSString *)fileName fromDirectory:(DirectoryType)directory;

/**
 *  移动文件
 */
+ (BOOL)moveLocalFile:(NSString *)fileName
        fromDirectory:(DirectoryType)origin
          toDirectory:(DirectoryType)destination;

/**
 *  移动某个文件去某个文件夹
 *  @param folderName 文件夹名，没有会创建
 */
+ (BOOL)moveLocalFile:(NSString *)fileName
        fromDirectory:(DirectoryType)origin
          toDirectory:(DirectoryType)destination
       withFolderName:(NSString *)folderName;

/**
 *  复制文件
 */
+ (BOOL)copyFileAtPath:(NSString *)origin
            toNewPath:(NSString *)destination;

/**
 *  重命名
 *
 *  @param origin  原始主目录
 *  @param path    sub路径
 *  @param oldName 旧文件名
 *  @param newName 新文件名
 */
+ (BOOL)renameFileFromDirectory:(DirectoryType)origin
                         atPath:(NSString *)path
                    withOldName:(NSString *)oldName
                     andNewName:(NSString *)newName;

/**
 *  通过给定的key，获取App seting
 */
+ (id)getAppSettingsForObjectWithKey:(NSString *)objKey;

/**
 *  通过给定的key，存储App seting
 */
+ (BOOL)setAppSettingsForObject:(id)value
                         forKey:(NSString *)objKey;


@end
