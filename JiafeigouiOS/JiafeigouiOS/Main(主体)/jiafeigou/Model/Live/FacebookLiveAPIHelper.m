//
//  FacebookLiveAPIHelper.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/13.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "FacebookLiveAPIHelper.h"

#import <FBSDKGraphRequest.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <FBSDKLoginManager.h>
#import <FBSDKLoginManagerLoginResult.h>
#import "JfgLanguage.h"

NSString *const LasetestLiveIDKey = @"lasetestLiveIDKey_";

@interface FacebookLiveAPIHelper()

@property (nonatomic,strong)FBSDKLoginManager *loginManager;
@property (nonatomic,copy)NSString *liveID;

@end

@implementation FacebookLiveAPIHelper

-(void)meLive
{
    //NSString *path = [NSString stringWithFormat:@"%@?end_live_video=true",self.liveID];
//    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/accounts" parameters:nil HTTPMethod:@"GET"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//        
//        if (!error) {
//            NSLog(@"fetched user:%@", result);
//        }
//        
//        
//        
//    }];
    
   
}

-(void)pageList
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/pages" parameters:nil HTTPMethod:@"GET"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        NSLog(@"%@",result);
        
    }];
}

-(void)groupListWithHandler:(void(^)(NSError *error,id result))handler
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_managed_groups"]) {
    
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/groups" parameters:nil HTTPMethod:@"GET"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if (handler) {
                handler(error,result);
            }
            
        }];
        
    }else{
        
        [self.loginManager logInWithReadPermissions:@[@"user_managed_groups"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
            if (!error) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/groups" parameters:nil HTTPMethod:@"GET"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    
                    if (handler) {
                        handler(error,result);
                    }


                }];
            }else{
                
                if (handler) {
                    handler(error,result);
                }

            }
            
        }];
        
    }
}

-(void)userNameWithHandler:(void(^)(NSError *error,id result))handler
{
    if ([FBSDKAccessToken currentAccessToken]) {
        
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:[FBSDKAccessToken currentAccessToken].userID];
        if (userName) {
            
            self.userName = userName;
            NSDictionary *dict = @{@"id":[FBSDKAccessToken currentAccessToken].userID,@"name":userName};
            NSLog(@"%@",[FBSDKAccessToken currentAccessToken].userID);
            if (handler) {
                handler(nil,dict);
            }
            
        }else{
            
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,name,email" forKey:@"fields"];
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                /*  {
                 id = 274952073020580;
                 name = "\U5218\U5fd7\U5e73";
                 }   */
                if (!error) {
                    if ([result isKindOfClass:[NSDictionary class]]) {
                        
                        NSDictionary *dict = result;
                        NSString *name = [dict objectForKey:@"name"];
                        NSString *_id = [dict objectForKey:@"id"];
                        [[NSUserDefaults standardUserDefaults] setObject:name forKey:_id];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        self.userName = name;
                    }
                }
                
                if (handler) {
                    handler(error,result);
                }
                NSLog(@"%@",result);
                
            }];
            
            
        }
        
    }else{
        
        if (handler) {
            NSError *error = [[NSError alloc]initWithDomain:@"www.facebook.com" code:52 userInfo:nil];
            handler(error,nil);
        }
        
    }
}



-(void)createLiveWithHandler:(void(^)(NSError *error,id result))handler
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        
        NSNumber *chooseNum = [[NSUserDefaults standardUserDefaults] objectForKey:FBLiveVideoAuthorityKey];
        if (!chooseNum) {
            chooseNum = @(0);
        }
            /*
             enum{'EVERYONE', 'ALL_FRIENDS', 'FRIENDS_OF_FRIENDS', 'CUSTOM', 'SELF'}
             */
            
        
        NSString *privacy = @"";
        if ([chooseNum intValue] == FBPrivacyTypeFriends) {
            privacy = @"{\"value\":\"ALL_FRIENDS\"}";

        }else if ([chooseNum intValue] == FBPrivacyTypeSelf){
            privacy = @"{\"value\":\"SELF\"}";

        }else if ([chooseNum intValue] == FBPrivacyTypeFriendsOfFriends){
            privacy = @"{\"value\":\"FRIENDS_OF_FRIENDS\"}";

        }else{
            privacy = @"{\"value\":\"EVERYONE\"}";
        }
        
        
        NSString *path = [NSString stringWithFormat:@"%@/live_videos",[FBSDKAccessToken currentAccessToken].userID];
        
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@"LIVE_NOW" forKey:@"status"];
        
        [dic setObject:privacy forKey:@"privacy"];
        [dic setObject:@"true" forKey:@"is_spherical"];
        [dic setObject:@"true" forKey:@"stop_on_delete_stream"];
        NSString *ti = [[NSUserDefaults standardUserDefaults] objectForKey:FBLiveVideoTitleKey];
        if (ti) {
            [dic setObject:ti forKey:@"title"];
            [dic setObject:ti forKey:@"description"];
        }else{
            [dic setObject:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"] forKey:@"title"];
            [dic setObject:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"] forKey:@"description"];
        }
        
        /*
         description=我正在使用Unicam720°全景摄像机进行直播, status=LIVE_NOW, privacy={value:"EVERYONE"}, is_spherical=true, stop_on_delete_stream=true, title=我正在使用Unicam720°全景摄像机进行直播, stream_type=AMBIENT
         */
        
//        [dic setObject:time forKey:@"planned_start_time"];
        
        /*
         enum{'EVERYONE', 'ALL_FRIENDS', 'FRIENDS_OF_FRIENDS', 'CUSTOM', 'SELF'}
         @{@"status":@"LIVE_NOW",@"planned_start_time":time}
         UNPUBLISHED  LIVE_NOW
         */
        [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:dic HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                NSLog(@"fetched user:%@", result);
                if ([result isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dict = result;
                    self.liveID = dict[@"id"];
                    [[NSUserDefaults standardUserDefaults] setObject:self.liveID forKey:LasetestLiveIDKey];
                }
                
            }
            if (handler) {
                handler(error,result);
            }
        }];
        
    }else{
       
        [self.loginManager logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (!error) {
                
                NSString *path = [NSString stringWithFormat:@"%@/live_videos",[FBSDKAccessToken currentAccessToken].userID];
                NSNumber *chooseNum = [[NSUserDefaults standardUserDefaults] objectForKey:FBLiveVideoAuthorityKey];
                if (!chooseNum) {
                    chooseNum = @(0);
                }
                /*
                 enum{'EVERYONE', 'ALL_FRIENDS', 'FRIENDS_OF_FRIENDS', 'CUSTOM', 'SELF'}
                 */
                
                
                NSString *privacy = @"";
                if ([chooseNum intValue] == FBPrivacyTypeFriends) {
                    privacy = @"{\"value\":\"ALL_FRIENDS\"}";
                    
                }else if ([chooseNum intValue] == FBPrivacyTypeSelf){
                    privacy = @"{\"value\":\"SELF\"}";
                    
                }else if ([chooseNum intValue] == FBPrivacyTypeFriendsOfFriends){
                    privacy = @"{\"value\":\"FRIENDS_OF_FRIENDS\"}";
                    
                }else{
                    privacy = @"{\"value\":\"EVERYONE\"}";
                }
                
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:@"LIVE_NOW" forKey:@"status"];
                [dic setObject:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"] forKey:@"description"];
                [dic setObject:privacy forKey:@"privacy"];
                [dic setObject:@"true" forKey:@"is_spherical"];
                [dic setObject:@"true" forKey:@"stop_on_delete_stream"];
                [dic setObject:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"] forKey:@"title"];
                [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:dic HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    
                    if (!error) {
                        NSLog(@"fetched user:%@", result);
                        if ([result isKindOfClass:[NSDictionary class]]) {
                            
                            NSDictionary *dict = result;
                            self.liveID = dict[@"id"];
                        }
                    }
                    
                    if (handler) {
                        handler(error,result);
                    }
                    
                }];
                
            }
        }];
        
    }
}

-(void)endLiveWithHandler:(void(^)(NSError *error,id result))handler
{
    if (self.liveID == nil) {
        self.liveID = [[NSUserDefaults standardUserDefaults] objectForKey:LasetestLiveIDKey];
    }
    
    if (self.liveID && ![self.liveID isEqualToString:@""]) {
        
        ///{live_video_id}?end_live_video=true
        //NSString *path = [NSString stringWithFormat:@"%@?end_live_video=true",self.liveID];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:self.liveID parameters:@{@"end_live_video":@(true)} HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                NSLog(@"fetched user:%@", result);
            }
            
            if (handler) {
                handler(error,result);
            }
            
        }];
        
    }else{
        
        if (handler) {
            NSError *error = [[NSError alloc]initWithDomain:@"" code:52 userInfo:nil];
            handler(error,nil);
        }
        
    }
}

-(void)loginFromViewController:(UIViewController *)vc handler:(void (^)(NSError *error))handler
{
    if ([FBSDKAccessToken currentAccessToken]) {
        if (handler) {
            handler(nil);
        }
    }else{
        [self.loginManager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:vc handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
            
            
            if (error) {
                NSLog(@"FBLoginError:%@",error);
            }else if (result.isCancelled){
                NSLog(@"FBLogin isCancelled");
            }else{
                [FBSDKAccessToken setCurrentAccessToken:result.token];
                NSLog(@"FBLogin In %@",result.token.permissions);
            }
            if (handler) {
                handler(error);
            }
            
        }];
    }
    
}

-(void)deleteLiveWithHandler:(void(^)(NSError *error,id result))handler
{
    if (self.liveID == nil) {
        self.liveID = [[NSUserDefaults standardUserDefaults] objectForKey:LasetestLiveIDKey];
    }

    if (self.liveID && ![self.liveID isEqualToString:@""]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:self.liveID parameters:nil HTTPMethod:@"DELETE"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                NSLog(@"fetched user:%@", result);
            }
            
            if (handler) {
                handler(error,result);
            }
            
        }];
        
    }else{
        
        if (handler) {
            NSError *error = [[NSError alloc]initWithDomain:@"" code:52 userInfo:nil];
            handler(error,nil);
        }
        
    }
}

-(void)loginOut
{
    [self.loginManager logOut];
}

+(FBSDKAccessToken *)currentToken
{
    return [FBSDKAccessToken currentAccessToken];
}

-(FBSDKLoginManager *)loginManager
{
    if (!_loginManager) {
        _loginManager = [[FBSDKLoginManager alloc]init];
    }
    return _loginManager;
}

+(NSArray *)fbPrivacy
{
    return @[[JfgLanguage getLanTextStrByKey:@"FACEBOOK_PERMISSIONS_PUBLIC"],[JfgLanguage getLanTextStrByKey:@"FACEBOOK_PERMISSIONS_FRIENDS"],[JfgLanguage getLanTextStrByKey:@"FACEBOOK_PERMISSIONS_ONLYME"],[JfgLanguage getLanTextStrByKey:@"FACEBOOK_PERMISSIONS_FRIENDS_OF_FRIENDS"]];
}

+(NSString *)privacyForIndex:(FBPrivacyType)type
{
    NSArray *arr = [[self class] fbPrivacy];
    if (arr.count > type) {
        return arr[type];
    }
    return nil;
}

/*
 id = 274998956349225;
 "secure_stream_secondary_urls" =     (
 );
 "secure_stream_url" = "rtmps://live-api-a.facebook.com:443/rtmp/274998956349225?ds=1&s_l=1&a=ATgnbuThj-Hjs3bh";
 "stream_secondary_urls" =     (
 );
 "stream_url" = "rtmp://live-api-a.facebook.com:80/rtmp/274998956349225?ds=1&s_l=1&a=ATgnbuThj-Hjs3bh";
 */

@end
