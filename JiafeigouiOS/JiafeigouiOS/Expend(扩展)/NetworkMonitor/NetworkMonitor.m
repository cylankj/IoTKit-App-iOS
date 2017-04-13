
//
//  NetworkMonitor.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/26.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "NetworkMonitor.h"


@interface NetworkMonitor()
{
    NSHashTable *_hashTabel;
}

@property (nonatomic,strong)Reachability *reachability;

@end

@implementation NetworkMonitor

+(instancetype)sharedManager
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

-(id)init
{
    self = [super init];
    _hashTabel = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:0];
    return self;
}

-(void)starMonitor
{
    [self.reachability startNotifier];
}

-(void)stopMonitor
{
    [self.reachability stopNotifier];
}

-(void)addDelegate:(id<NetworkMonitorDelegate>)delegate
{
    [_hashTabel addObject:delegate];
}

-(void)removeDelegate:(id<NetworkMonitorDelegate>)delegate
{
    [_hashTabel removeObject:delegate];
}

-(Reachability *)reachability
{
    if (!_reachability) {
        
        __block id blockSelf = self;
        _reachability = [Reachability reachabilityForInternetConnection];
        _reachability.reachableBlock = ^(Reachability * reachability){
            [blockSelf updateInterfaceWithReachability:reachability];
        };
        _reachability.unreachableBlock =^(Reachability * reachability){
            [blockSelf updateInterfaceWithReachability:reachability];
        };
        NetworkStatus netStatus = [_reachability currentReachabilityStatus];
        _currentNetworkStatu = netStatus;
        
    }
    return _reachability;
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    _currentNetworkStatu = netStatus;
    [self respondDelegate:netStatus];
    NSString* statusString = @"";
    switch (netStatus)
    {
            //断开连接
        case NotReachable:{
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
                       /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            break;
        }
            
            //3G/4G网络
        case ReachableViaWWAN:        {
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            
            break;
        }
            //wifi
        case ReachableViaWiFi:        {
            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            
            break;
        }
    }
    NSLog(@"%@",statusString);
}


-(void)respondDelegate:(NetworkStatus)statu
{
    for (id<NetworkMonitorDelegate>delegate in _hashTabel) {
        
        if ([delegate respondsToSelector:@selector(networkChanged:)]) {
            
            [delegate networkChanged:statu];
            
        }
    }
}

@end
