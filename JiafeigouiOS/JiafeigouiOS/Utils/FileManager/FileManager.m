//
//  FileManager.m
//  LXYProject
//
//  Created by apple on 15/8/26.
//  Copyright (c) 2015年 liuxinyan. All rights reserved.
//

#import "FileManager.h"
#import "JfgConstKey.h"


@implementation FileManager
+(FileManager *)shared
{
    static FileManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[FileManager alloc] init];
    });
    
    return _shared;
    
}
+(NSString *)dirHome{
    return NSHomeDirectory();
}
//获取Documents目录
+(NSString *)dirDoc{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"app_home_doc: %@",documentsDirectory);
    return documentsDirectory;
}
//获取Library目录
+(NSString *)dirLib{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
//获取Cache目录
+(NSString *)dirCache{
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [cacPath objectAtIndex:0];

}
//获取Tmp目录
+(NSString *)dirTmp{
   return  NSTemporaryDirectory();
}
//创建文件夹
+(BOOL)createDir:(NSString *)documentsPath DirStr:(NSString *) dir{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:dir];
    // 创建目录
    return [fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];

}
//创建文件
+(NSString *)createFile:(NSString *) FileName forPath:(NSString *) documentsPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testPath = [documentsPath stringByAppendingPathComponent:FileName];
    BOOL res=[fileManager createFileAtPath:testPath contents:nil attributes:nil];
    if (res) {
        return testPath;
    }else
        return @"+1";
}
//写文件
+(BOOL)writeFile:(NSString *)FilePath text:(NSString *)content{
   return [content writeToFile:FilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

}
//读文件
+(NSString *)readFile:(NSString *)FilePath{
    return [NSString stringWithContentsOfFile:FilePath encoding:NSUTF8StringEncoding error:nil];
}
//文件属性
+(NSArray *)fileAttriutes:(NSString *)FilePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:FilePath error:nil];

    return [fileAttributes allKeys];
   }
//删除文件
+(BOOL)deleteFile:(NSString *)FilePath{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res=[fileManager removeItemAtPath:FilePath error:nil];
    if (res) {
        if ([fileManager isExecutableFileAtPath:FilePath]) {
            return NO;
        }else{
            return YES;
        }
    }else
        return NO;

}

#pragma mark
#pragma mark  jfg docment
+ (NSString *)jfgPano720PhotoDirPath:(NSString *)cid
{
    NSString *homeDoc = [self dirDoc];
    NSString *currentAccount = [[LoginManager sharedManager] currentLoginedAcount];
    return [NSString stringWithFormat:@"%@/%@/%@/%@", homeDoc,currentAccount,cid,pano720MediaPath];
}

+ (NSString *)jfgLogDirPath
{
    NSString *homeDoc = [self dirDoc];
    NSString *path = [homeDoc stringByAppendingPathComponent:jfgWorkDocment];
    return path;
}

+ (NSString *)jfgUpgradeFilePath:(int)deviceType
{
    NSString *path = [[self jfgLogDirPath] stringByAppendingString:[NSString stringWithFormat:@"DogUpdateFile_%d.bin",deviceType]];
    return path;
}

@end
