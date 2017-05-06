//
//  JfgHttp.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/4/22.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface JfgHttp : NSObject

@property (nonatomic, readonly)AFHTTPSessionManager *httpManager;


+ (instancetype)sharedHttp;

#pragma mark request
- (NSURLSessionDataTask *)get:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress *downloadProgress))progress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)post:(NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress *progress))progress
                       success:(void (^)(NSURLSessionDataTask *task, id reponseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark download
- (void)downLoadWithURLString:(NSString *)URLString toPath:(NSString *)filePath completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
@end
