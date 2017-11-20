//
//  YoutubeLiveAPIHelper.m
//  JiafeigouiOS
//
//  Created by yangli on 2017/9/6.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "YoutubeLiveAPIHelper.h"


@interface YoutubeLiveAPIHelper()<YoutubeSignInDelegate>

@property (nonatomic,strong)YoutubeLiveStreamingAPI *liveAPI;
@property (nonatomic,strong)YoutubeLiveStreamsModel *liveModel;

@end

@implementation YoutubeLiveAPIHelper

-(void)signInWithPresentVC:(UIViewController *)VC
{
    [self.liveAPI signInWithPresentVC:VC];
}

-(void)signOut
{
    [self.liveAPI signOut];
}

-(void)createLiveChannelWithTitle:(NSString *)title
                      description:(NSString *)description
                        startTime:(NSDate *)startDate
                          endTime:(NSDate *)endDate
                              cid:(NSString *)cid
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
    [self performSelector:@selector(reqTimeout) withObject:nil afterDelay:10];
    __weak typeof(self) weakSelf = self;
    
    self.liveModel.cid = cid;
    self.liveModel.title = title;
    self.liveModel.scheduledStartTime = startDate;
    self.liveModel.scheduledEndTime = endDate;
    self.liveModel.isValid = NO;
    
    //创建频道
    [self.liveAPI createLiveBroadcastWithTitle:title description:description startTime:startDate endTime:endDate completionHandler:^(id object, NSError *error) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        if (!error) {
            
            //创建视频流通道
            [weakSelf.liveAPI createLiveStreamsWithTitle:title completionHandler:^(id object, NSError *error) {
                
                if (!error) {
                    
                    //绑定视频流与频道
                    [weakSelf.liveAPI bindLiveBroadcastID:weakSelf.liveAPI.currentLiveBoradcast.identifier withLiveStreamID:weakSelf.liveAPI.currentliveStream.identifier completionHandler:^(id object, NSError *error) {
                        
                        if (!error) {
                            
                            weakSelf.liveModel.liveBroadcastID = weakSelf.liveAPI.currentLiveBoradcast.identifier;
                            weakSelf.liveModel.liveStreamsID = weakSelf.liveAPI.currentliveStream.identifier;
                            weakSelf.liveModel.watchUrl = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",weakSelf.liveAPI.currentLiveBoradcast.identifier];
                            weakSelf.liveModel.streamsUrl = [NSString stringWithFormat:@"%@/%@",weakSelf.liveAPI.currentliveStream.cdn.ingestionInfo.ingestionAddress,weakSelf.liveAPI.currentliveStream.cdn.ingestionInfo.streamName];
                            weakSelf.liveModel.isValid = YES;
                            weakSelf.liveModel.title = weakSelf.liveAPI.currentLiveBoradcast.snippet.title;
                            weakSelf.liveModel.descrips = weakSelf.liveAPI.currentLiveBoradcast.snippet.descriptionProperty;
                            weakSelf.liveModel.cid = cid;
                            weakSelf.liveModel.scheduledStartTime = startDate;
                            weakSelf.liveModel.scheduledEndTime = endDate;
                            
                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(createLiveChannelResultForError:liveModel:)]) {
                                [weakSelf.delegate createLiveChannelResultForError:nil liveModel:weakSelf.liveModel];
                            }
                            
                        }else{
                            [weakSelf createLiveChannelFaield:error];
                        }
                        
                    }];
                    
                }else{
                    [weakSelf createLiveChannelFaield:error];
                }
            }];
            
        }else{
            [weakSelf createLiveChannelFaield:error];
        }

        
    }];
}


-(void)createLiveChannelFaield:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(createLiveChannelResultForError:liveModel:)]) {
        [self.delegate createLiveChannelResultForError:error liveModel:self.liveModel];
    }

}

-(void)checkLiveStreamStateForIdentifier:(NSString *)identifier
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
    [self performSelector:@selector(reqTimeout) withObject:nil afterDelay:10];
    __weak typeof(self) weakSelf = self;
    [self.liveAPI liveStreamsListWithCompletionHandler:^(id object, NSError *error) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        if ([object isKindOfClass:[GTLRYouTube_LiveStreamListResponse class]]) {
            
            GTLRYouTube_LiveStreamListResponse *liveBroadcastList = object;
            BOOL isExist = NO;
            for (GTLRYouTube_LiveStream *liveStream in liveBroadcastList.items) {
                if ([identifier isEqualToString:liveStream.identifier]) {
                    isExist = YES;
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(liveStreamForIdentifier:streamStatus:healthStatus:error:)]) {
                        [weakSelf.delegate liveStreamForIdentifier:liveStream.identifier streamStatus:liveStream.status.streamStatus healthStatus:liveStream.status.healthStatus.status error:nil];
                        
                        NSLog(@"statue:%@",liveStream.status.streamStatus);
                        NSLog(@"title:%@",liveStream.snippet.title);
                        NSLog(@"healthStatue:%@",liveStream.status.healthStatus.status);
                        break;
                    }
                }
            }
            //revoked
            if (!isExist) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(liveStreamForIdentifier:streamStatus:healthStatus:error:)]) {
                    [weakSelf.delegate liveStreamForIdentifier:identifier streamStatus:@"revoked" healthStatus:@"revoked" error:nil];
                }
            }
        }else{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(liveStreamForIdentifier:streamStatus:healthStatus:error:)]) {
                [weakSelf.delegate liveStreamForIdentifier:identifier streamStatus:@"" healthStatus:@"" error:error];
            }
        }
    }];
}


-(void)checkLiveBroadcastStateForIdentifier:(NSString *)identifier
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
    [self performSelector:@selector(reqTimeout) withObject:nil afterDelay:10];
    __weak typeof(self) weakSelf = self;
    [self.liveAPI liveBroadcastListWithCompletionHandler:^(id object, NSError *error) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        if ([object isKindOfClass:[GTLRYouTube_LiveBroadcastListResponse class]]) {
            
            BOOL isExist = NO;
            GTLRYouTube_LiveBroadcastListResponse *liveBroadcastList = object;
            for (GTLRYouTube_LiveBroadcast *liveBroadcast in liveBroadcastList.items) {
                
                if ([liveBroadcast.identifier isEqualToString:identifier]) {
                    isExist = YES;
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(liveBroadcastForIdentifier:lifeCycleStatus:error:)]) {
                        [weakSelf.delegate liveBroadcastForIdentifier:identifier lifeCycleStatus:liveBroadcast.status.lifeCycleStatus error:nil];
                        break;
                    }
                    
                }
                
            }
            if (!isExist) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(liveBroadcastForIdentifier:lifeCycleStatus:error:)]) {
                    [weakSelf.delegate liveBroadcastForIdentifier:identifier lifeCycleStatus:@"revoked" error:nil];
                }
            }
            
        }else{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(liveBroadcastForIdentifier:lifeCycleStatus:error:)]) {
                [weakSelf.delegate liveBroadcastForIdentifier:identifier lifeCycleStatus:@"" error:error];
            }
        }
    }];
}

-(void)transitionBroadcastStatue:(NSString *)statue identifier:(NSString *)identifier
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
    [self performSelector:@selector(reqTimeout) withObject:nil afterDelay:10];
    __weak typeof(self) weakSelf = self;
    [self.liveAPI liveBroadcastsTransitionStatue:statue forLiveBroadcastID:identifier completionHandler:^(id object, NSError *error) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
        if ([object isKindOfClass:[GTLRYouTube_LiveBroadcast class]]) {
            
            GTLRYouTube_LiveBroadcast *liveBroadcast = object;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(transitionBroadcastStatueResultForIdentifier:lifeCycleStatus:error:)]) {
                
                [weakSelf.delegate transitionBroadcastStatueResultForIdentifier:identifier lifeCycleStatus:liveBroadcast.status.lifeCycleStatus error:error];
                
            }
            
        }else{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(transitionBroadcastStatueResultForIdentifier:lifeCycleStatus:error:)]) {
                
                [weakSelf.delegate transitionBroadcastStatueResultForIdentifier:identifier lifeCycleStatus:@"" error:error];
                
            }
            
        }
    }];
}

-(void)reqTimeout
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveReqTimeout)]) {
        [self.delegate liveReqTimeout];
    }
}

#pragma mark- signIn Delegate
-(void)signInSuccessForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(signInResultForError:)]) {
        [self.delegate signInResultForError:nil];
    }
}

-(void)signInDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(signInResultForError:)]) {
        [self.delegate signInResultForError:error];
    }
}

-(YoutubeLiveStreamingAPI *)liveAPI
{
    if (!_liveAPI) {
        _liveAPI = [[YoutubeLiveStreamingAPI alloc]init];
        _liveAPI.delegate = self;
    }
    return _liveAPI;
}

-(YoutubeLiveStreamsModel *)liveModel
{
    if (!_liveAPI) {
        _liveModel = [[YoutubeLiveStreamsModel alloc]init];
    }
    return _liveModel;
}

-(GIDGoogleUser *)signInUser
{
    return [GIDSignIn sharedInstance].currentUser;
}

@end
