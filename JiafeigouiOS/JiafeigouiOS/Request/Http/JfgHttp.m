//
//  JfgHttp.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/4/22.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JfgHttp.h"
#import <JFGSDK/JFGSDK.h>

@interface JfgHttp()

@property (nonatomic, strong)AFHTTPSessionManager *httpManager;

@end

@implementation JfgHttp

+ (instancetype)sharedHttp
{
    static dispatch_once_t onceToken;
    static JfgHttp *httpRequest;
    
    dispatch_once(&onceToken, ^{
        httpRequest = [[JfgHttp alloc] init];
    });
    
    return httpRequest;
}

- (NSURLSessionDataTask *)get:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress *downloadProgress))progress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"get request url: [%@]",URLString]];
    if (URLString != nil)
    {
        return [self.httpManager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress)
            {
                progress(downloadProgress);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success)
            {
                success(task, responseObject);
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"response %@", responseObject]];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure)
            {
                failure(task,error);
            }
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"get request error: [%@]",error]];
        }];
    }
    return nil;
}


- (NSURLSessionDataTask *)post:(NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress *progress))progress
                       success:(void (^)(NSURLSessionDataTask *task, id reponseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"post request url: [%@]",URLString]];
    
    return [self.httpManager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"post request error: [%@]",error]];
    }];
}

#pragma mark donwload

- (void)downLoadWithURLString:(NSString *)URLString toPath:(NSString *)filePath completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *destinationURL = [NSURL fileURLWithPath:filePath];
        NSLog(@"destion URL [%@]", destinationURL);
        return destinationURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        if (completionHandler)
        {
            completionHandler(response, filePath, error);
        }
    }];
    [downloadTask resume];
}

- (AFHTTPSessionManager *)httpManager
{
    //AFNetworking的bug，防止内存泄漏
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _httpManager = [AFHTTPSessionManager manager];
        _httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        //_httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    });
    return _httpManager;
}

@end
