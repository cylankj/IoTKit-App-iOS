//
//  EfamilyRequest.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/9/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "EfamilyRequest.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/MPMessagePackReader.h>
#import <JFGSDK/MPMessagePackWriter.h>







@interface EfamilyRequest()<JFGSDKCallbackDelegate>
{
    NSString *_mac;
    NSString *_cid;
    NSString *_alias;
    NSInteger bindCount;
}
@end

@implementation EfamilyRequest

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [JFGSDK addDelegate:self];
        
    }
    return self;
}

-(void)bindDeviceZKWithMac:(NSString *)mac cid:(NSString *)cid alias:(NSString *)alias
{
    _mac = mac;
    _cid = cid;
    _alias = alias;
    bindCount = 0;
    [self bingDeviceZKWithMac:mac cid:cid alias:alias isQBind:NO];
    
}

-(void)bingDeviceZKWithMac:(NSString *)mac cid:(NSString *)cid alias:(NSString *)alias isQBind:(BOOL)isQB
{
//    MsgClientAddDevice addDeviceMsg;
//    addDeviceMsg.mac = [mac UTF8String];
//    addDeviceMsg.cid = [cid UTF8String];
//    addDeviceMsg.alias = [alias UTF8String];
//    addDeviceMsg.mCallee = [cid UTF8String];
//    if (isQB) {
//        addDeviceMsg.is_rebind = 1;
//    }else{
//        addDeviceMsg.is_rebind = 0;
//    }
//    std::string head = getBuff(addDeviceMsg);
//    NSData *data = [NSData dataWithBytes:head.c_str() length:head.length()];
//    [JFGSDK sendEfamilyMsgData:data];
}

- (void)efamilyRequestWithDict:(NSDictionary *)dict
{

    

}
- (void)efamilyRequestWithCid:(NSString *)cid {
    //    发送中控消息示例代码，勿删
//    MsgHeader msgHeader;
//    msgHeader.mId = 1092;
//    msgHeader.mCaller = "";
//    msgHeader.mCallee = [cid UTF8String];
    
   // std::string head = getBuff(msgHeader);
    
   // NSData *data = [NSData dataWithBytes:head.c_str() length:head.length()];
    //204
   // [JFGSDK sendEfamilyMsgData:data];
}



#pragma mark JFGSDK  Delegate
- (void)jfgEfamilyMsg:(id)msg
{
    if ([msg isKindOfClass:[NSArray class]]) {
        
        NSArray *msgList = msg;
        if (msgList.count && ([msgList[0] isKindOfClass:[NSNumber class]] && [msgList[0] integerValue] == 16219)) {
            
            if (msgList.count == 5) {
                
                bindCount ++;
                if ( [msgList[4] isKindOfClass:[NSNumber class]]) {
                    int result = [msgList[4] integerValue];
                    
                    if (result == 8 || result == 204) {
                        if (bindCount < 5) {
                            [self bingDeviceZKWithMac:_mac cid:_cid alias:_alias isQBind:YES];
                            return;
                        }
                    }
                }
                
            }else if (msgList.count == 6){
                
                
                if ( [msgList[4] isKindOfClass:[NSNumber class]] && [msgList[4] integerValue] == 0) {
                    
                    if ([_delegate respondsToSelector:@selector(efamilyResponseResult:)])
                    {
                        [_delegate efamilyResponseResult:YES];
                    }
                    return;
                }
                
            }
            
            
        }
        
        
    }
    
    if ([_delegate respondsToSelector:@selector(efamilyResponseResult:)])
    {
        [_delegate efamilyResponseResult:NO];
    }
}

@end
