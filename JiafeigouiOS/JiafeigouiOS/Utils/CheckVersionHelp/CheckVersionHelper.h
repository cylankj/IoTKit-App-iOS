//
//  CheckVersionHelper.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/25.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckVersionHelper : NSObject

@property (nonatomic, assign) BOOL isForeceUpgrade;
@property (nonatomic, copy) NSString *url;

/*
 * 
 **/
- (void)checkVersion;

@end
