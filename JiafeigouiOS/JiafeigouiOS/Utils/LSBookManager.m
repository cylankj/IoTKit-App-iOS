//
//  LSBookManager.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "LSBookManager.h"
#import "LoginManager.h"

@implementation LSBookManager

static LSBookManager * instance = nil;
+ (LSBookManager *)sharedManager{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[self alloc]init];
        }
    }
    return instance;
}
//获得plist路径
-(NSString*)getPlistPath{
    //沙盒中的文件路径
    NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
    JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
    NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"HelpAndFeedback_%@.plist",account.account]];       //根据需要更改文件名
    return plistPath;
}
//判断沙盒中名为plistname的文件是否存在
-(BOOL) isPlistFileExists{
    NSString *plistPath =[[LSBookManager sharedManager] getPlistPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if( [fileManager fileExistsAtPath:plistPath]== NO ) {
        NSLog(@"not exists");
        return NO;
    }else{
        return YES;
    }
}
-(void)initPlist{
    NSString *plistPath = [[LSBookManager sharedManager] getPlistPath];
    
    //如果plist文件不存在，将工程中已建起的plist文件写入沙盒中
    if (![[LSBookManager sharedManager] isPlistFileExists]) {
        //从自己建立的plist文件 复制到沙盒中
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"HelpAndFeedback" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath:plistPath error:&error];
    }
}
-(NSMutableArray*)readPlist{
    
    NSString *plistPath = [self getPlistPath];
    NSMutableArray *resultArray = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
    return resultArray;
}
//删除plistPath路径对应的文件
-(void)deletePlist{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *plistPath = [[LSBookManager sharedManager] getPlistPath];
    [fileManager removeItemAtPath:plistPath error:nil];
    
}
//将dictionary写入plist文件，前提：dictionary已经准备好
-(void)writePlist:(NSMutableDictionary *)dic{
    
    NSMutableArray * plistArray = [[NSMutableArray alloc]init];
    
    //如果已存在则读取现有数据
    if ([[LSBookManager sharedManager]isPlistFileExists]) {
        plistArray = [[LSBookManager sharedManager]readPlist];
    }
    
    for (NSDictionary *alwayDic in plistArray) {
        if ([[alwayDic objectForKey:@"msgDate"] isEqualToString:[dic objectForKey:@"msgDate"]] && [[alwayDic objectForKey:@"msg"] isEqualToString:[dic objectForKey:@"msg"]] ) {
            return;
        }
    }
    
    //增加一个数据
    [plistArray addObject:dic];
    
    NSString *plistPath = [[LSBookManager sharedManager] getPlistPath];
    
    if([plistArray writeToFile:plistPath atomically:YES]){
        NSLog(@"write ok!");
    }else{
        NSLog(@"ddd");
    }
    
}
@end
