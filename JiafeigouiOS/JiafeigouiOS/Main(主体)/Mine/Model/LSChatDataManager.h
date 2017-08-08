//
//  LSChatDataManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/4/21.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSChatModel.h"

@interface LSChatDataManager : NSObject

@property (nonatomic,readonly)NSMutableArray <LSChatModel *> *chatModelList;

+(instancetype)shareChatDataManager;
-(BOOL)addChatModel:(LSChatModel *)chatModel;
-(void)replaceChatModel:(LSChatModel *)chatModel;
-(void)removeChatModel:(LSChatModel *)chatModel;
-(void)removeAllChatModel;

@end
