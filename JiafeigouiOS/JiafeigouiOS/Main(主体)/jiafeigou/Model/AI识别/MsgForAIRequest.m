//
//  MsgForAIRequest.m
//  JiafeigouiOS
//
//  Created by yangli on 2017/10/23.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "MsgForAIRequest.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/MPMessagePackReader.h>
#import <JFGSDK/MPMessagePackWriter.h>
#import <JFGSDK/JFGSDK.h>
#import "OemManager.h"
#import "FLLog.h"

@interface MsgForAIRequest()<JFGSDKCallbackDelegate>
@property (nonatomic,strong)NSMutableDictionary *parameterDict;
@end

@implementation MsgForAIRequest

-(void)addJfgDelegate
{
    [JFGSDK addDelegate:self];
}

-(void)removeJfgDelegate
{
    [JFGSDK removeDelegate:self];
}

//获取访客列表
-(void)reqFamiliarPersonsForCid:(NSString *)cid timestamp:(int)timestamp
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(timestamp)] error:nil] cid:cid forMsgID:5];
}

//获取陌生人列表
-(void)reqStrangerListForCid:(NSString *)cid timestamp:(int)timestamp
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(timestamp)] error:nil] cid:cid forMsgID:6];
}

-(void)reqMsgDelAccess:(NSString *)access_id isFamiliar:(BOOL)isFamiliar delMsgAndHeader:(BOOL)delAll cid:(NSString *)cid
{
    int type = 0;
    int delMsg = 0;
    if (isFamiliar) {
        type = 2;
    }else{
        type = 1;
    }
    
    if (delAll) {
        delMsg = 1;
    }else{
        delMsg = 0;
    }
    uint64_t seq = [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(type),access_id,@(delMsg)] error:nil] cid:cid forMsgID:9];
    if (seq !=0) {
        [self.parameterDict setObject:@[cid,access_id] forKey:[NSString stringWithFormat:@"%lld",seq]];
    }
}

-(void)reqAccessCountForType:(int)type accessID:(NSString *)accessID cid:(NSString *)cid
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(type),accessID] error:nil] cid:cid forMsgID:7];
}

//获取熟悉人名字
-(void)reqPersonNameForID:(NSString *)persion_id cid:(NSString *)cid
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,persion_id] error:nil] cid:cid forMsgID:10];
}

-(void)reqRobotHost
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[@"",[OemManager getOemVid]] error:nil] cid:@"" forMsgID:12];
}

//cid, type, id, timeMsec
-(void)reqMsgForType:(int)type accessID:(NSString *)accessID cid:(NSString *)cid timestamp:(int64_t)timestamp
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(type),accessID,@(timestamp)] error:nil] cid:cid forMsgID:8];
}

//获取熟悉人面孔列表
-(void)reqFaceIDListForPerson:(NSString *)person_id cid:(NSString *)cid
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,person_id] error:nil] cid:cid forMsgID:11];
}

-(void)jfgOnUniversalData:(NSData *)msgData msgID:(int)mid seq:(long)seq
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    
    if (mid == 5) {
        
        //访客列表
        //NSLog(@"mid:%d %@",mid,obj);
        int total = 0;
        NSMutableArray *personModelList = [NSMutableArray new];
        if ([obj isKindOfClass:[NSArray class]]) {
            
            NSArray *sourceArr = obj;
            if (sourceArr.count>1) {
                
                total = [sourceArr[0] intValue];
                id secoudObj = sourceArr[1];
                if ([secoudObj isKindOfClass:[NSArray class]]) {
                    
                    NSArray *personArr = secoudObj;
                    for (NSArray *person in personArr) {
                        
                        if ([person isKindOfClass:[NSArray class]] && person.count>3) {
                            
                            FamiliarPersonsModel *model = [FamiliarPersonsModel new];
                            
                            model.last_time = [person[3] intValue];
                            model.person_id = person[1];
                            if (model.person_id == nil) {
                                model.person_id = @"";
                            }
                            model.person_name = person[2];
                            model.object_type = [person[0] intValue];
                            
                            NSMutableArray *strangerArr = [NSMutableArray new];
                            NSMutableArray *faceIDArr = [NSMutableArray new];
                            
                            NSArray *faceImageArr = person[4];
                            if ([faceImageArr isKindOfClass:[NSArray class]]) {
                                
                                for (NSArray *faceArr in faceImageArr) {
                                    
                                    if ([faceArr isKindOfClass:[NSArray class]] && faceArr.count>2) {
                                        
                                        /*
                                         face_id1,
                                         image_url1,
                                         oss_type1
                                         */
                                        NSString *faceID = faceArr[0];
                                        NSString *faceImageUrl = faceArr[1];
                                        int flag = [faceArr[2] intValue];
                                        StrangerModel *m = [StrangerModel new];
                                        m.face_id = faceID;
                                        m.faceImageUrl = [JFGSDK getCloudUrlWithFlag:flag fileName:faceImageUrl];
                                        [strangerArr addObject:m];
                                        [faceIDArr addObject:faceID];
                                    }
                                    
                                }
                                
                            }
                            model.face_id = [[NSArray alloc]initWithArray:faceIDArr];
                            model.strangerArr = [[NSArray alloc]initWithArray:strangerArr];
                            
                            if (model.person_id && ![model.person_id isEqualToString:@""]) {
                                [personModelList addObject:model];
                            }
                            
                            
                        }
                    }
                }
            }
        }

        
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgForAIFamiliarPersons:total:)]) {
            [self.delegate msgForAIFamiliarPersons:personModelList total:total];
        }
        //FLLog(@"熟悉人总数:%d %@",total,personModelList);
        
    }else if (mid == 6){
        
        //陌生人列表
        int total = 0;
        NSMutableArray *personModelList = [NSMutableArray new];
        if ([obj isKindOfClass:[NSArray class]]) {
            
            NSArray *sourceArr = obj;
            if (sourceArr.count>1) {
                
                total = [sourceArr[0] intValue];
                id secoudObj = sourceArr[1];
                if ([secoudObj isKindOfClass:[NSArray class]]) {
                    
                    NSArray *personArr = secoudObj;
                    for (NSArray *person in personArr) {
                        
                        if ([person isKindOfClass:[NSArray class]] && person.count>3) {
                            
                            /*
                             20171102154608CPWqGQTLSAxjc8S50j,
                             /7day/0001/18503060168/AI/290100000002/1509608763_8.jpg,
                             0,
                             1509608804
                             */
                            StrangerModel *model = [StrangerModel new];
                            model.face_id = person[0];
                            model.faceImageUrl = person[1];
                            model.flag = [person[2] intValue];
                            model.last_time = [person[3] intValue];
                            model.faceImageUrl = [JFGSDK getCloudUrlWithFlag:model.flag fileName:model.faceImageUrl];
                            
                            //FLLog(@"陌生人face_id:%@",model.face_id);
                            if (model.face_id && ![model.face_id isEqualToString:@""]) {
                                [personModelList addObject:model];
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgForAIStranger:total:)]) {
            [self.delegate msgForAIStranger:personModelList total:total];
        }
        //FLLog(@"陌生人总数:%d %@",total,personModelList);
        
    }else if (mid == 7){
        
        //来访人数统计
        NSArray *sourceOjb = obj;
        if ([sourceOjb isKindOfClass:[NSArray class]] && sourceOjb.count>3) {
            
            NSString *cid = sourceOjb[0];
            //int type = [sourceOjb[1] intValue];
            NSString *face_id = [sourceOjb objectAtIndex:2];
            int count = [sourceOjb[3] intValue];
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgForAIAccessCount:face_id:cid:)]) {
                
                [self.delegate msgForAIAccessCount:count face_id:face_id cid:cid];
                
            }
        }
        
    }else if (mid == 8){
        
        //FLLog(@"%@",obj);
        NSMutableArray *resultArr = [NSMutableArray new];
        NSString *cid = @"";
        int type = 0;
        NSString *access_id = @"";
        //int timestamp = 0;
        NSArray *sourceObj1 = obj;
        if ([sourceObj1 isKindOfClass:[NSArray class]] && sourceObj1.count>4) {
            
            //cid, type, id, timeMsec, [dpdata1, dpdata2, ...
            cid = sourceObj1[0];
            type = [sourceObj1[1] intValue];
            access_id = sourceObj1[2];
            //timestamp = [sourceObj1[3] intValue];
            NSArray *dataArray = sourceObj1[4];
            if ([dataArray isKindOfClass:[NSArray class]]) {
                for (NSArray *data in dataArray) {
                    
                    if ([data isKindOfClass:[NSArray class]] && data.count>2) {
                        
                        int64_t timestamp = [data[1] longLongValue];
                        int msgID = [data[0] intValue];
                        MessageModel *messageModel = [[MessageModel alloc] init];
                        if (msgID == 505 || msgID == 512) {
                            
                            messageModel.msgID = 505;
                            messageModel.realyMsgID = msgID;
                            //messageModel.cid = cid;
                            messageModel._version = timestamp;
                            NSArray *values = [MPMessagePackReader readData:data[2] error:nil];
                            messageModel.timestamp = [[values objectAtIndex:0] longLongValue];
                            messageModel.is_record = [[values objectAtIndex:1] boolValue];
                            messageModel.flag = [[values objectAtIndex:3] intValue];
                            messageModel.imageNum = [[values objectAtIndex:2] intValue];
                            if (values.count>4) {
                                messageModel.tly = [values objectAtIndex:4];
                            }else{
                                messageModel.tly = @"1";
                            }
                            
                            if (values.count > 5) {
                                messageModel.objects = [values objectAtIndex:5];
                                //NSLog(@"renxingjiance:%@",messageModel.objects);
                            }else{
                                messageModel.objects = nil;
                            }
                            
                            if (values.count > 6) {
                                messageModel.manNum = [values[6] intValue];
                            }else{
                                messageModel.manNum = 0;
                            }
                            if (values.count>7) {
                                messageModel.face_idList = values[7];
                            }
                            if (msgID == 512) {
                                messageModel.deviceVersion = 3;
                            }else{
                                messageModel.deviceVersion = 2;
                            }
                            
                            [resultArr addObject:messageModel];
                            
                        }
                    }
                    
                }

            }
            
            
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgForAIAllMsg:cid:access_id:type:)]) {
            [self.delegate msgForAIAllMsg:resultArr cid:cid access_id:access_id type:type];
        }
    }else if (mid == 9){
        
        NSString *cid = @"";
        NSString *access_id = @"";
        NSArray *arr = [self.parameterDict objectForKey:[NSString stringWithFormat:@"%ld",seq]];
    
        if (arr && arr.count>1) {
            cid = arr[0];
            access_id = arr[1];
            [self.parameterDict removeObjectForKey:[NSString stringWithFormat:@"%ld",seq]];
        }
        int ret = 1;
        if ([obj isKindOfClass:[NSNumber class]]) {
            ret = [obj intValue];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgForAIDelMsgWithCid:access_id:ret:)]) {
            [self.delegate msgForAIDelMsgWithCid:cid access_id:access_id ret:ret];
        }
    }else if (mid == 10){
        
        if ([obj isKindOfClass:[NSArray class]]) {
            
            NSArray *objArr = obj;
            //cid, person_id, name
            if (objArr.count>2) {
                
                NSString *cid = objArr[0];
                NSString *person_id = objArr[1];
                NSString *name = objArr[2];
                if (self.delegate && [self.delegate respondsToSelector:@selector(msgForAIPersonName:person_id:cid:)]) {
                    [self.delegate msgForAIPersonName:name person_id:person_id cid:cid];
                }
                
            }
            
        }
        
    }else if (mid == 11){
        
        if ([obj isKindOfClass:[NSArray class]]) {
            
            NSArray *objArr = obj;
            if (objArr.count>1) {
                
                NSMutableArray *faceidList = [NSMutableArray new];
                NSString *cid = objArr[0];
                NSString *person_id = objArr[1];
                if (objArr.count>2) {
                    
                    NSArray *fcl = objArr[2];
                    for (NSArray *daa in fcl) {
                        
                        if (daa.count>2) {
                            StrangerModel *md = [StrangerModel new];
                            NSString *face_id = daa[0];
                            NSString *imageUrl = daa[1];
                            md.face_id = face_id;
                            md.flag = [daa[2] intValue];
                            md.faceImageUrl = [JFGSDK getCloudUrlWithFlag:md.flag fileName:imageUrl];
                            [faceidList addObject:md];
                        }
                        
                    }
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(msgForAIFaceList:cid:person_id:)]) {
                    [self.delegate msgForAIFaceList:faceidList cid:cid person_id:person_id];
                }
                
            }
        }
        
    }else if (mid == 12){
        
        NSArray *objArr = obj;
        if ([objArr isKindOfClass:[NSArray class]] && objArr.count>1) {
            
            NSString *host = objArr[0];
            NSString *port = objArr[1];
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgForRobotHost:post:)]) {
                [self.delegate msgForRobotHost:host post:port];
            }
        }
        
    }
}

-(NSMutableDictionary *)parameterDict
{
    if (!_parameterDict) {
        _parameterDict = [NSMutableDictionary new];
    }
    return _parameterDict;
}

@end

