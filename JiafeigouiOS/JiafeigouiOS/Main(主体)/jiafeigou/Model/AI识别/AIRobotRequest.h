//
//  AIRobotRequest.h
//  JiafeigouiOS
//
//  Created by yangli on 2017/10/19.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIRobotRequest : NSObject

//注册与修改 (有person_id就填，没有就不填，face_id也一样)
+(void)robotRegisterFace:(NSString *)face_id
                  person:(NSString *)person_id
                     cid:(NSString *)cid
              personName:(NSString *)personName
                  sucess:(void (^)(id responseObject))sucess
                 failure:(void (^)(NSError *error))failur;

//给某个person增加face
+(void)robotAddFace:(NSString *)face_id
           toPerson:(NSString *)person_id
                cid:(NSString *)cid
             sucess:(void (^)(id responseObject))sucess
            failure:(void (^)(NSError *error))failur;

//删除人脸，如果是删除person下得face，填写person_id,如果不是可以不填person_id
+(void)robotDelFaceIDList:(NSArray *)face_idList
                person_id:(NSString *)person_id
                      cid:(NSString *)cid
                   sucess:(void (^)(id responseObject))sucess
                  failure:(void (^)(NSError *error))failur;

//删除person
+(void)robotDelPerson:(NSString *)person_id
                  cid:(NSString *)cid
               sucess:(void (^)(id responseObject))sucess
              failure:(void (^)(NSError *error))failur;


+(void)afNetWorkingForAIRobotWithUrl:(NSString *)url
                          patameters:(NSDictionary *)parameters
                              sucess:(void (^)(id responseObject))sucess
                             failure:(void (^)(NSError *error))failure;

//获取签名
+(NSString *)signForReqPath:(NSString *)reqPath
         service_key_secret:(NSString *)secret
                  timestamp:(int)timestamp;

//AI服务url
+(NSString *)aiServiceReqUrl;

@end
