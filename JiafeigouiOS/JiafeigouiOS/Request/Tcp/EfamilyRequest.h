//
//  EfamilyRequest.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/9/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol efamilyRequeseDelegate <NSObject>

@required

- (void)efamilyResponseResult:(BOOL)success;

@end


@interface EfamilyRequest : NSObject

@property (nonatomic, assign) id<efamilyRequeseDelegate> delegate;

//绑定中控
-(void)bindDeviceZKWithMac:(NSString *)mac cid:(NSString *)cid alias:(NSString *)alias;

@end
