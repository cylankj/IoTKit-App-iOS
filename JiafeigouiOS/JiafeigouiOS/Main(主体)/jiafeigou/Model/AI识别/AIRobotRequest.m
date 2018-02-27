//
//  AIRobotRequest.m
//  JiafeigouiOS
//
//  Created by yangli on 2017/10/19.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AIRobotRequest.h"
#import "NSData+FLExtension.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AFNetworking.h>
#import "AIBase64.h"
#import <JFGSDK/JFGSDK.h>
#import "OemManager.h"
#import "LoginManager.h"

@implementation AIRobotRequest


+ (void)afNetWorkingForAIRobotWithUrl:(NSString *)url
                          patameters:(NSDictionary *)parameters
                              sucess:(void (^)(id responseObject))sucess
                             failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Robot:%@",responseObject);
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"grayerror:%@",error);
        if (failure) {
            failure(error);
        }
    }];
}

+(NSString *)aiServiceReqUrl
{
    /*
     https://yun.jfgou.com:8085/aiapp
     http://yun.jfgou.com:8082/aiapp
     */
    NSString *url = [NSString stringWithFormat:@"http://%@:8082/aiapp",[[self class] reqHost]];
    NSLog(@"url%@",url);
    return url;
}

+(NSString *)reqHost
{
    NSString *jfgServer = [[NSUserDefaults standardUserDefaults] objectForKey:@"_jfg_changedDomain_"];
    if (jfgServer && [jfgServer isKindOfClass:[NSString class]] && ![jfgServer isEqualToString:@""]) {
        
        NSRange range = [jfgServer rangeOfString:@":"];
        if (range.location !=NSNotFound && range.location>1) {
            
            NSString *addr = [jfgServer substringToIndex:range.location];
            return addr;
        }else{
            return @"yun.jfgou.com";
        }
        
    }else{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString *addr = [infoDictionary objectForKey:@"Jfgsdk_host"];
        if (!addr || [addr isEqualToString:@""]) {
            addr = @"yun.jfgou.com";
        }
        return addr;
    }
    
    
}


+ (NSString *)hmacSha1:(NSString*)key text:(NSString*)text
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash;
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
}

+(NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

+(NSString *)signForReqPath:(NSString *)reqPath service_key_secret:(NSString *)secret timestamp:(int)timestamp
{
    NSString *dataStr = [NSString stringWithFormat:@"%@\n%d",reqPath,timestamp];
    NSString * hmac = [[self class] hmacSha1:secret text:dataStr];
    NSData *inputData = [hmac dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64str = [inputData base64EncodedString];
    NSString *signature = [[self class] URLEncodedString:base64str];
    return signature;
}

+(NSString *)getService_key
{
//    NSString *vid = [OemManager getOemVid];
//    if ([vid isEqualToString:@"0001"]) {
//        return @"qg9vRfvofK9b4xsWh1kHnEb998lQZYwA";
//    }else{
//        return @"PB14hf9peVw6CBoVS7Gs4LcMfcOzWNKR";
//    }
    return @"qg9vRfvofK9b4xsWh1kHnEb998lQZYwA";
}

+(NSString *)getService_key_seceret
{
//    NSString *vid = [OemManager getOemVid];
//    if ([vid isEqualToString:@"0001"]) {
//        return @"VQ9jvWXe4YhJbhrPepqH7zaRppuUGNSf";
//    }else{
//        return @"B8nxU7u3GUDukGlBbjeidOVmYhtPApn0";
//    }
    return @"VQ9jvWXe4YhJbhrPepqH7zaRppuUGNSf";
}

//必要参数
+(NSMutableDictionary *)requisiteParameterWithUrl:(NSString *)url cid:(NSString *)cid
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    int timestamp = (int)[[NSDate date] timeIntervalSince1970];
    NSString *sign = [AIRobotRequest signForReqPath:url service_key_secret:[[self class] getService_key_seceret] timestamp:timestamp];
    NSString *access_token = [JFGSDK getSession];
    [dict setObject:@"0001" forKey:@"vid"];
    [dict setObject:[[self class] getService_key] forKey:@"service_key"];
    [dict setObject:@"1" forKey:@"business"];
    [dict setObject:@"1" forKey:@"service_type"];
    [dict setObject:sign forKey:@"sign"];
    [dict setObject:[NSString stringWithFormat:@"%d",timestamp] forKey:@"timestamp"];
    [dict setObject:cid forKey:@"sn"];
    [dict setObject:access_token forKey:@"access_token"];
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    JFGSDKAcount *acm = [[LoginManager sharedManager] accountCache];
    if (acm) {
        account = acm.account;
    }
    [dict setObject:account forKey:@"account"];
    return dict;
}

+(void)robotDelPerson:(NSString *)person_id
                  cid:(NSString *)cid
               sucess:(void (^)(id responseObject))sucess
              failure:(void (^)(NSError *error))failur
{
    NSMutableDictionary *dict = [[self class] requisiteParameterWithUrl:@"/aiservice/v1/del_person" cid:cid];
    [dict setObject:person_id forKey:@"person_id"];
    //@"http://yf.robotscloud.com/aiservice/v1/del_person"
    [AIRobotRequest afNetWorkingForAIRobotWithUrl:[self robtoUrlForConfig:@"aiservice/v1/del_person"] patameters:dict sucess:^(id responseObject) {
        NSLog(@"%@",responseObject);
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(NSError *error) {
        
        if (failur) {
            failur(error);
        }
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"萝卜头接口（aiservice/v1/del_person）请求错误：%@",error.userInfo.description]];
    }];
}


+(NSString *)robtoUrlForConfig:(NSString *)cofig
{
    NSString *host = [[NSUserDefaults standardUserDefaults]objectForKey:oemRobotHostKey];
    if (!host) {
        host = @"yun.robotscloud.com";
    }
    //@"http://yf.robotscloud.com/aiservice/v1/del_person"
    NSString *url = [NSString stringWithFormat:@"http://%@/%@",host,cofig];
    return url;
}

+(void)robotDelFaceIDList:(NSArray *)face_idList
                person_id:(NSString *)person_id
                      cid:(NSString *)cid
                   sucess:(void (^)(id responseObject))sucess
                  failure:(void (^)(NSError *error))failur
{
    NSMutableDictionary *dict = [[self class] requisiteParameterWithUrl:@"/aiservice/v1/del_face_app" cid:cid];
    if (!face_idList.count) {
        return;
    }
    NSMutableString *faceListStr = [NSMutableString new];
    for (NSString *face_id in face_idList) {
        if ([faceListStr isEqualToString:@""]) {
            [faceListStr appendString:face_id];
        }else{
            [faceListStr appendString:[NSString stringWithFormat:@",%@",face_id]];
        }
    }
    
    [dict setObject:faceListStr forKey:@"face_id"];
    if (person_id && ![person_id isKindOfClass:@""]) {
        [dict setObject:person_id forKey:@"person_id"];
    }
    [AIRobotRequest afNetWorkingForAIRobotWithUrl:[self robtoUrlForConfig:@"aiservice/v1/del_face_app"] patameters:dict sucess:^(id responseObject) {
        NSLog(@"%@",responseObject);
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(NSError *error) {
        
        if (failur) {
            failur(error);
        }
         [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"萝卜头接口（aiservice/v1/del_face_app）请求错误：%@",error.userInfo.description]];
    }];
}

+(void)robotAddFace:(NSString *)face_id
           toPerson:(NSString *)person_id
                cid:(NSString *)cid
             sucess:(void (^)(id responseObject))sucess
            failure:(void (^)(NSError *error))failur
{
    NSMutableDictionary *dict = [[self class] requisiteParameterWithUrl:@"/aiservice/v1/edit_face_app" cid:cid];
    [dict setObject:face_id forKey:@"face_id"];
    [dict setObject:person_id forKey:@"person_id"];
    
    //NSLog(@"%@",dict);
    
    //@"http://yf.robotscloud.com/aiservice/v1/edit_face_app"
    [AIRobotRequest afNetWorkingForAIRobotWithUrl:[self robtoUrlForConfig:@"aiservice/v1/edit_face_app"] patameters:dict sucess:^(id responseObject) {
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(NSError *error) {
        
        if (failur) {
            failur(error);
        }
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"萝卜头接口（/aiservice/v1/edit_face_app）请求错误：%@",error.userInfo.description]];
    }];
}

+(void)robotRegisterFace:(NSString *)face_id
                  person:(NSString *)person_id
                     cid:(NSString *)cid
              personName:(NSString *)personName
                  sucess:(void (^)(id responseObject))sucess
                 failure:(void (^)(NSError *error))failur
{
    NSMutableDictionary *dict = [self requisiteParameterWithUrl:@"/aiservice/v1/reg_face_app" cid:cid];
    
    [dict setObject:personName forKey:@"person_name"];
    if (face_id && ![face_id isEqualToString:@""]) {
         [dict setObject:face_id forKey:@"face_id"];
    }
    if (person_id && ![person_id isEqualToString:@""]) {
        [dict setObject:person_id forKey:@"person_id"];
    }
    //@"http://yf.robotscloud.com/aiservice/v1/reg_face_app"
    [AIRobotRequest afNetWorkingForAIRobotWithUrl:[self robtoUrlForConfig:@"aiservice/v1/reg_face_app"] patameters:dict sucess:^(id responseObject) {
        NSLog(@"%@",responseObject);
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(NSError *error) {

        if (failur) {
            failur(error);
        }
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"萝卜头接口（aiservice/v1/reg_face_app）请求错误：%@",error.userInfo.description]];
    }];
    
}

@end
