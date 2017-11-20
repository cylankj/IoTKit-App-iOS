//
//  YoutubeLiveStreamingAPI.h
//  YoutubeLiveVideo-OC
//
//  Created by 杨利 on 2017/9/4.
//  Copyright © 2017年 yangli. All rights reserved.
//  Youtube直播流相关

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleSignIn/GIDSignIn.h>
#import <GoogleSignIn/GIDAuthentication.h>
#import <GoogleSignIn/GIDGoogleUser.h>
#import <GoogleSignIn/GIDProfileData.h>
#import <GTLRYouTube.h>

@protocol YoutubeSignInDelegate <NSObject>

//授权登录成功
- (void)signInSuccessForUser:(GIDGoogleUser *)user
                   withError:(NSError *)error;

//授权登录失败
- (void)signInDisconnectWithUser:(GIDGoogleUser *)user
                       withError:(NSError *)error;

@end

@interface YoutubeLiveStreamingAPI : NSObject

//授权登录代理
@property (nonatomic,weak)id <YoutubeSignInDelegate> delegate;

//当前直播频道（创建后才有）
@property (nonatomic,strong)GTLRYouTube_LiveBroadcast *currentLiveBoradcast;

//当前直播流（创建后才有）
@property (nonatomic,strong)GTLRYouTube_LiveStream *currentliveStream;

//登录授权（一下操作必须登录授权成功后操作）
-(void)signInWithPresentVC:(UIViewController *)VC;

//退出授权登录
-(void)signOut;

//创建频道
-(void)createLiveBroadcastWithTitle:(NSString *)title
                        description:(NSString *)description
                          startTime:(NSDate *)startDate
                            endTime:(NSDate *)endDate
                  completionHandler:(void (^)(id object,NSError *error))handler;

//创建直播流
-(void)createLiveStreamsWithTitle:(NSString *)title
                completionHandler:(void (^)(id object,NSError *error))handler;

//绑定直播流与直播频道
-(void)bindLiveBroadcastID:(NSString *)liveBroadcastID
          withLiveStreamID:(NSString *)liveStreamID
         completionHandler:(void (^)(id object,NSError *error))handler;


// 切换直播频道状态
-(void)liveBroadcastsTransitionStatue:(NSString *)statue
                   forLiveBroadcastID:(NSString *)liveBroadcastID
                    completionHandler:(void (^)(id object,NSError *error))handler;

//删除直播流
-(void)liveStreamDeleteForID:(NSString *)liveStreamID
           completionHandler:(void (^)(id object,NSError *error))handler;


//删除直播频道
-(void)liveBroadcastDeleteForID:(NSString *)liveBroadcastID
              completionHandler:(void (^)(id object,NSError *error))handler;

//获取直播流列表
-(void)liveStreamsListWithCompletionHandler:(void (^)(id object,NSError *error))handler;

//获取直播频道列表
-(void)liveBroadcastListWithCompletionHandler:(void (^)(id object,NSError *error))handler;

@end
