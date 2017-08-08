//
//  JFGSDKSockCBDelegate.h
//  JFGSDK
//
//  Created by yangli on 2017/3/16.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFGSDKSockCBDelegate <NSObject>

-(void)jfgSockConnect;

-(void)jfgSockDisconnect;

-(void)jfgMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID
                                             mSeq:(uint64_t)mSeq
                                              cid:(NSString *)cid
                                             type:(int)type
                                          msgData:(NSData *)msgData;

-(void)jfgDPMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID
                                              mSeq:(uint64_t)mSeq
                                               cid:(NSString *)cid
                                              type:(int)type
                                      isInitiative:(BOOL)initiative
                                           dpMsgArr:(NSArray *)dpMsgArr;

@end
