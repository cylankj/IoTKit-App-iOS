//
//  MsgForAIRequest.h
//  JiafeigouiOS
//
//  Created by yangli on 2017/10/23.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"
#import "MsgForAIModel.h"

@protocol MsgForAIRequestDelegate <NSObject>

@optional

//获取熟悉人列表回调
-(void)msgForAIFamiliarPersons:(NSArray <FamiliarPersonsModel *>*)models total:(int)total;
//获取陌生人列表回调
-(void)msgForAIStranger:(NSArray <StrangerModel *> *)models total:(int)total;
//获取某个人访问次数回调
-(void)msgForAIAccessCount:(int)count face_id:(NSString *)face_id cid:(NSString *)cid;
//获取某人访问详细信息回调
-(void)msgForAIAllMsg:(NSArray <MessageModel *> *)msgList cid:(NSString *)cid access_id:(NSString *)access_id type:(int)type;
//删除
-(void)msgForAIDelMsgWithCid:(NSString *)cid access_id:(NSString *)access_id ret:(int)ret;
//获取person_name
-(void)msgForAIPersonName:(NSString *)personName person_id:(NSString *)person_id cid:(NSString *)cid;
//获取熟人面孔列表
-(void)msgForAIFaceList:(NSArray <StrangerModel *>*)faceList cid:(NSString *)cid person_id:(NSString *)person_id;
//萝卜头地址
-(void)msgForRobotHost:(NSString *)host post:(NSString *)post;

@end

@interface MsgForAIRequest : NSObject

@property (nonatomic,weak)id <MsgForAIRequestDelegate> delegate;

-(void)addJfgDelegate;
-(void)removeJfgDelegate;
//请求熟悉人列表
-(void)reqFamiliarPersonsForCid:(NSString *)cid timestamp:(int)timestamp;
//请求陌生人列表
-(void)reqStrangerListForCid:(NSString *)cid timestamp:(int)timestamp;
//请求访问次数(type 检索条件：1-陌生人 2-已注册人物 3-一周时间 4-一个月时间)
-(void)reqAccessCountForType:(int)type accessID:(NSString *)accessID cid:(NSString *)cid;
//请求详细访问信息
-(void)reqMsgForType:(int)type accessID:(NSString *)accessID cid:(NSString *)cid timestamp:(int64_t)timestamp;
//删除face对应的消息或者面孔（delAll  yes:则删除消息与头像，NO:仅删除头像）
-(void)reqMsgDelAccess:(NSString *)access_id isFamiliar:(BOOL)isFamiliar delMsgAndHeader:(BOOL)delAll cid:(NSString *)cid;
//获取熟悉人名字
-(void)reqPersonNameForID:(NSString *)persion_id cid:(NSString *)cid;
//获取熟悉人面孔列表
-(void)reqFaceIDListForPerson:(NSString *)person_id cid:(NSString *)cid;
//获取萝卜头地址
-(void)reqRobotHost;

@end
