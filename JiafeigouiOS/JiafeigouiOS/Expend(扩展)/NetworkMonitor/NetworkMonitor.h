//
//  NetworkMonitor.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/26.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

/**
 
 网络监测
 
 **/

#import <Foundation/Foundation.h>
#import <Reachability/Reachability.h>
@protocol NetworkMonitorDelegate;

@interface NetworkMonitor : NSObject

/**
 *  当前网络状态
 */
@property (nonatomic,assign)NetworkStatus currentNetworkStatu;


/**
 *  单例
 *
 *  @return 单例对象
 */
+(instancetype)sharedManager;


/**
 *  开始监测网络
 */
-(void)starMonitor;


/**
 *  停止监测网络
 */
-(void)stopMonitor;


/**
 *  添加网络变化回调代理
 *
 *  @note weak对象，不会引起释放问题
 *  @param delegate 代理
 */
-(void)addDelegate:(id<NetworkMonitorDelegate>)delegate;

/**
 *  移除回调代理
 */
-(void)removeDelegate:(id<NetworkMonitorDelegate>)delegate;

@end


@protocol NetworkMonitorDelegate <NSObject>

@optional
/**
 *  网络变化回调
 *
 *  @param statu 网络状态
 */
-(void)networkChanged:(NetworkStatus)statu;

@end