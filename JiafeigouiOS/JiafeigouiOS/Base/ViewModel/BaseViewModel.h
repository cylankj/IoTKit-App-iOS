//
//  BaseViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JfgTypeDefine.h"

@interface BaseViewModel : NSObject

@property (nonatomic, copy) NSString *cid;

@property (nonatomic, assign) productType pType;

@property (nonatomic, assign) BOOL isShare;

@end
