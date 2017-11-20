//
//  YoutubeLiveStreamingAPI.m
//  YoutubeLiveVideo-OC
//
//  Created by 杨利 on 2017/9/4.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import "YoutubeLiveStreamingAPI.h"
#import "YoutubeConfig.h"
#import "YoutubeLiveStreamsModel.h"

@interface YoutubeLiveStreamingAPI()<GIDSignInUIDelegate,GIDSignInDelegate>

@property (nonatomic,weak)UIViewController *presentViewController;
@property (nonatomic,strong)GTLRYouTubeService *youtubeService;


@end

@implementation YoutubeLiveStreamingAPI



-(void)signInWithPresentVC:(UIViewController *)VC
{
    if ([GIDSignIn sharedInstance].currentUser) {
        //已经授权登录，直接返回结果
        if (self.delegate && [self.delegate respondsToSelector:@selector(signInSuccessForUser:withError:)]) {
            [self.delegate signInSuccessForUser:[GIDSignIn sharedInstance].currentUser withError:nil];
        }
        return;
    }
    self.presentViewController = VC;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].clientID = ytbClientID;
    //这个很重要，设置需要获取的API权限
    [GIDSignIn sharedInstance].scopes = [NSArray arrayWithObjects:kGTLRAuthScopeYouTube,kGTLRAuthScopeYouTubeForceSsl,kGTLRAuthScopeYouTubeReadonly, nil];
    //授权登录
    [[GIDSignIn sharedInstance] signIn];
    
}

-(void)signOut
{
    [[GIDSignIn sharedInstance] signOut];
}

//创建频道
-(void)createLiveBroadcastWithTitle:(NSString *)title
                        description:(NSString *)description
                          startTime:(NSDate *)startDate
                            endTime:(NSDate *)endDate
                  completionHandler:(void (^)(id object,NSError *error))handler
{
    GTLRYouTube_LiveBroadcastSnippet *broadcastSnippet = [[GTLRYouTube_LiveBroadcastSnippet alloc]init];
    broadcastSnippet.title = title;
    broadcastSnippet.descriptionProperty = description;
    broadcastSnippet.scheduledStartTime = [GTLRDateTime dateTimeWithDate:startDate];
    if (!startDate) {
        broadcastSnippet.scheduledStartTime = [GTLRDateTime dateTimeWithDate:[NSDate date]];
    }else{
        broadcastSnippet.scheduledStartTime = [GTLRDateTime dateTimeWithDate:startDate];
    }
    if (endDate) {
        broadcastSnippet.scheduledEndTime = [GTLRDateTime dateTimeWithDate:endDate];
    }
    
    GTLRYouTube_LiveBroadcastStatus *broadcastStatus = [[GTLRYouTube_LiveBroadcastStatus alloc]init];
    broadcastStatus.privacyStatus = kGTLRYouTube_LiveBroadcastStatus_PrivacyStatus_Public;
    
    GTLRYouTube_LiveBroadcastContentDetails *contentDetails = [[GTLRYouTube_LiveBroadcastContentDetails alloc]init];
    contentDetails.projection = kGTLRYouTube_LiveBroadcastContentDetails_Projection_X360;//设置360度全景视频
    
    GTLRYouTube_LiveBroadcast *liveBroadcast = [[GTLRYouTube_LiveBroadcast alloc]init];
    liveBroadcast.kind = @"youtube#liveBroadcast";
    liveBroadcast.status = broadcastStatus;
    liveBroadcast.snippet = broadcastSnippet;
    liveBroadcast.contentDetails = contentDetails;
    
    GTLRYouTubeQuery_LiveBroadcastsInsert *liveBroadcastsInsert = [GTLRYouTubeQuery_LiveBroadcastsInsert queryWithObject:liveBroadcast part:@"snippet,status"];
    
    
    [self.youtubeService executeQuery:liveBroadcastsInsert completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        if ([object isKindOfClass:[GTLRYouTube_LiveBroadcast class]]) {
            self.currentLiveBoradcast = object;
            NSLog(@"LiveBroadcast_id:%@",self.currentLiveBoradcast.identifier);
        }
        if (handler) {
            handler(object,callbackError);
        }
        NSLog(@"%@ %@",object,callbackError);
        
    }];
}


-(void)createLiveStreamsWithTitle:(NSString *)title
                completionHandler:(void (^)(id object,NSError *error))handler
{
    GTLRYouTube_LiveStreamSnippet *broadcastSnippet = [[GTLRYouTube_LiveStreamSnippet alloc]init];
    broadcastSnippet.title = title;
    
    
    GTLRYouTube_CdnSettings *cdnSetting = [[GTLRYouTube_CdnSettings alloc]init];
    cdnSetting.format = @"480p";
    cdnSetting.frameRate = @"30fps";
    cdnSetting.resolution = @"480p";
    cdnSetting.ingestionType = kGTLRYouTube_CdnSettings_IngestionType_Rtmp;
    
    GTLRYouTube_LiveStream *liveStream = [[GTLRYouTube_LiveStream alloc]init];
    liveStream.kind = @"youtube#liveStream";
    liveStream.snippet = broadcastSnippet;
    liveStream.cdn = cdnSetting;
    
    GTLRYouTubeQuery_LiveStreamsInsert *liveStreamsInsert = [GTLRYouTubeQuery_LiveStreamsInsert queryWithObject:liveStream part:@"snippet,cdn"];
    
    [self.youtubeService executeQuery:liveStreamsInsert completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        NSLog(@"%@ %@",object,callbackError);
        if ([object isKindOfClass:[GTLRYouTube_LiveStream class]]) {
            
            
            GTLRYouTube_LiveStream *resposeLiveStream = object;
            self.currentliveStream = resposeLiveStream;
            GTLRYouTube_CdnSettings *resposeCdnSetting = resposeLiveStream.cdn;
            GTLRYouTube_IngestionInfo *ingestionInfo = resposeCdnSetting.ingestionInfo;
            NSLog(@"LiveStream_id:%@ ingestionAddress:%@ streamName:%@",resposeLiveStream.identifier,ingestionInfo.ingestionAddress,ingestionInfo.streamName);
            NSLog(@"直播推流地址:%@/%@",ingestionInfo.ingestionAddress,ingestionInfo.streamName);
            
        }
        
        if (handler) {
            handler(object,callbackError);
        }
        
    }];
    
}


//一个频道只能绑定一个流，但是一个流可以绑定多个频道
-(void)bindLiveBroadcastID:(NSString *)liveBroadcastID
          withLiveStreamID:(NSString *)liveStreamID
         completionHandler:(void (^)(id object,NSError *error))handler
{
    GTLRYouTubeQuery_LiveBroadcastsBind *liveBroadcastsBind = [GTLRYouTubeQuery_LiveBroadcastsBind queryWithIdentifier:liveBroadcastID part:@"id,contentDetails"];
    liveBroadcastsBind.streamId =liveStreamID;
    [self.youtubeService executeQuery:liveBroadcastsBind completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        NSLog(@"%@ %@",object,callbackError);
        if ([object isKindOfClass:[GTLRYouTube_LiveBroadcast class]]) {
            
            GTLRYouTube_LiveBroadcast *liveBroadcast = object;
           
            if ([self.currentliveStream.identifier isEqualToString:liveStreamID]) {
                
//                YoutubeLiveStreamsModel *model = [YoutubeLiveModelManager sharedInstance].liveModel;
//                if (!model) {
//                    model = [[YoutubeLiveStreamsModel alloc]init];
//                }
//                model.liveStreamsID = liveStreamID;
//                model.liveBroadcastID = liveBroadcastID;
//                model.watchUrl = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",liveBroadcast.identifier];
//                model.streamsUrl = [NSString stringWithFormat:@"%@/%@",self.currentliveStream.cdn.ingestionInfo.ingestionAddress,self.currentliveStream.cdn.ingestionInfo.streamName];
                
                
            }
            //直播推流观看地址
            NSLog(@"watch address：%@",[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",liveBroadcast.identifier]);
            
        }
        if (handler) {
            handler(object,callbackError);
        }
        
    }];
}

/*
 
 @arg @c kGTLRYouTubeBroadcastStatusComplete The broadcast is over. YouTube
 *        stops transmitting video. (Value: "complete")
 *    @arg @c kGTLRYouTubeBroadcastStatusLive The broadcast is visible to its
 *        audience. YouTube transmits video to the broadcast's monitor stream
 *        and its broadcast stream. (Value: "live")
 *    @arg @c kGTLRYouTubeBroadcastStatusTesting Start testing the broadcast.
 *        YouTube transmits video to the broadcast's monitor stream. Note that
 *        you can only transition a broadcast to the testing state if its
 *        contentDetails.monitorStream.enableMonitorStream property is set to
 *        true. (Value: "testing")
 
 */

-(void)liveBroadcastsTransitionStatue:(NSString *)statue
                   forLiveBroadcastID:(NSString *)liveBroadcastID
                    completionHandler:(void (^)(id object,NSError *error))handler
{
    GTLRYouTubeQuery_LiveBroadcastsTransition *transition = [GTLRYouTubeQuery_LiveBroadcastsTransition queryWithBroadcastStatus:statue identifier:liveBroadcastID part:@"id,snippet,contentDetails,status"];
    [self.youtubeService executeQuery:transition completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        if (handler) {
            handler(object,callbackError);
        }
    }];
}

-(void)liveStreamDeleteForID:(NSString *)liveStreamID
           completionHandler:(void (^)(id object,NSError *error))handler
{
    GTLRYouTubeQuery_LiveStreamsDelete *liveStreamDelete = [GTLRYouTubeQuery_LiveStreamsDelete queryWithIdentifier:liveStreamID];
    [self.youtubeService executeQuery:liveStreamDelete completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        NSLog(@"%@ %@",object,callbackError);
        if (handler) {
            handler(object,callbackError);
        }
        
    }];
}

-(void)liveBroadcastDeleteForID:(NSString *)liveBroadcastID
              completionHandler:(void (^)(id object,NSError *error))handler
{
    GTLRYouTubeQuery_LiveBroadcastsDelete *lbd = [GTLRYouTubeQuery_LiveBroadcastsDelete queryWithIdentifier:liveBroadcastID];
    [self.youtubeService executeQuery:lbd completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        NSLog(@"%@ %@",object,callbackError);
        if (handler) {
            handler(object,callbackError);
        }
        if (callbackError == nil) {
            NSLog(@"删除成功");
        }
    }];
}

-(void)liveStreamsListWithCompletionHandler:(void (^)(id object,NSError *error))handler
{
    GTLRYouTubeQuery_LiveStreamsList *liveStreamsList = [GTLRYouTubeQuery_LiveStreamsList queryWithPart:@"id,snippet"];
    liveStreamsList.mine = YES;
    [self.youtubeService executeQuery:liveStreamsList completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        NSLog(@"%@ %@",object,callbackError);
        if ([object isKindOfClass:[GTLRYouTube_LiveStreamListResponse class]]) {
            
            GTLRYouTube_LiveStreamListResponse *liveBroadcastList = object;
            for (GTLRYouTube_LiveStream *liveStream in liveBroadcastList.items) {
                
                NSLog(@"statue:%@",liveStream.status.streamStatus);
                NSLog(@"title:%@",liveStream.snippet.title);
                NSLog(@"kind:%@",liveStream.kind);
                
            }
            
        }
        if (handler) {
            handler(object,callbackError);
        }
    }];
}

-(void)liveBroadcastListWithCompletionHandler:(void (^)(id object,NSError *error))handler
{
    GTLRYouTubeQuery_LiveBroadcastsList *liveBroadcastslist = [GTLRYouTubeQuery_LiveBroadcastsList queryWithPart:@"id,snippet"];
    liveBroadcastslist.broadcastType = kGTLRYouTubeBroadcastTypeAll;
    liveBroadcastslist.broadcastStatus = kGTLRYouTubeBroadcastStatusAll;

    [self.youtubeService executeQuery:liveBroadcastslist completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        NSLog(@"%@ %@",object,callbackError);
        if ([object isKindOfClass:[GTLRYouTube_LiveBroadcastListResponse class]]) {
            
            GTLRYouTube_LiveBroadcastListResponse *liveBroadcastList = object;
            for (GTLRYouTube_LiveBroadcast *liveBroadcast in liveBroadcastList.items) {
                
                NSLog(@"title:%@",liveBroadcast.snippet.title);
                NSLog(@"kind:%@",liveBroadcast.kind);
                NSLog(@"identifier:%@",liveBroadcast.identifier);
            
            }
            
        }
        if (handler) {
            handler(object,callbackError);
        }
        
    }];
}


#pragma mark- YoutubeDelegate
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    //[myActivityIndicator stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [self.presentViewController presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [self.presentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    // Perform any operations on signed in user here.
//    NSString *userId = user.userID;                  // For client-side use only!
//    NSString *idToken = user.authentication.idToken; // Safe to send to the server
//    NSString *fullName = user.profile.name;
//    NSString *givenName = user.profile.givenName;
//    NSString *familyName = user.profile.familyName;
//    NSString *email = user.profile.email;
    // ...
    
    if (!error) {
        NSLog(@"Youtube授权成功");
    }else{
        NSLog(@"Youtube授权失败：%@",error);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(signInSuccessForUser:withError:)]) {
        [self.delegate signInSuccessForUser:user withError:error];
    }
    
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    // Perform any operations when the user disconnects from app here.
    // ...
    if (self.delegate && [self.delegate respondsToSelector:@selector(signInDisconnectWithUser:withError:)]) {
        [self.delegate signInDisconnectWithUser:user withError:error];
    }
}

-(GTLRYouTubeService *)youtubeService
{
    if (!_youtubeService) {
        _youtubeService = [[GTLRYouTubeService alloc]init];
        _youtubeService.APIKey = ytbAPIKey;
    }
    _youtubeService.authorizer = [[GIDSignIn sharedInstance].currentUser.authentication fetcherAuthorizer];
    return _youtubeService;
}


@end
