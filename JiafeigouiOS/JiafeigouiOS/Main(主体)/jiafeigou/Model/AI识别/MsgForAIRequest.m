//
//  MsgForAIRequest.m
//  JiafeigouiOS
//
//  Created by yangli on 2017/10/23.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "MsgForAIRequest.h"
#import <JFGSDK/MPMessagePackReader.h>
#import <JFGSDK/MPMessagePackWriter.h>
#import <JFGSDK/JFGSDK.h>
#import "OemManager.h"
#import "JfgLanguage.h"
#import "FLLog.h"

//20260对应的消息ID
typedef NS_ENUM(NSInteger,MIDDataType) {
    
    MIDDataTypeVisitorList = 5,//访客列表
    MIDDataTypeStrangerList = 6,//陌生人列表
    MIDDataTypeVisitorName = 10,//访客(熟人)名称
    MIDDataTypeVisitorFaceList = 11,//访客(熟人)面孔列表
    MIDDataTypeRobotAddress = 12,//获取萝卜头域名
    MIDDataTypeVisitorCountEx = 19,//获取访问次数（时间范围内访问次数）新 19 旧  13
    MIDDataTypeVisitorCount = 16,//访问次数 新 16 旧  7
    MIDDataTypeVisitorMsg = 17,//访问消息 新 17  旧  8
    MIDDataTypeDelVisitorMsg = 18,//删除访问消息 新 18  旧  9
    
};


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
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(timestamp)] error:nil] cid:cid forMsgID:MIDDataTypeVisitorList];
}

-(void)reqVisitCountForCid:(NSString *)cid begintime:(int)beginTime endTime:(int)endTime
{
    //msgpack(cid, type, begin, end)
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(1),@(beginTime),@(endTime)] error:nil] cid:cid forMsgID:MIDDataTypeVisitorCountEx];
}

-(void)reqAIWarnMsgForCid:(NSString *)cid timestamp:(int)timestamp
{
    
}

//获取陌生人列表
-(void)reqStrangerListForCid:(NSString *)cid timestamp:(int)timestamp
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(timestamp)] error:nil] cid:cid forMsgID:MIDDataTypeStrangerList];
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
    uint64_t seq = [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(type),access_id,@(delMsg)] error:nil] cid:cid forMsgID:MIDDataTypeDelVisitorMsg];
    if (seq !=0) {
        [self.parameterDict setObject:@[cid,access_id] forKey:[NSString stringWithFormat:@"%lld",seq]];
    }
}

-(void)reqAccessCountForType:(int)type accessID:(NSString *)accessID cid:(NSString *)cid
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(type),accessID] error:nil] cid:cid forMsgID:MIDDataTypeVisitorCount];
}

//获取熟悉人名字
-(void)reqPersonNameForID:(NSString *)persion_id cid:(NSString *)cid
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,persion_id] error:nil] cid:cid forMsgID:MIDDataTypeVisitorName];
}

-(void)reqRobotHost
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[@"",[OemManager getOemVid]] error:nil] cid:@"" forMsgID:MIDDataTypeRobotAddress];
}

//cid, type, id, timeMsec
-(void)reqMsgForType:(int)type accessID:(NSString *)accessID cid:(NSString *)cid timestamp:(int64_t)timestamp
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,@(type),accessID,@(timestamp)] error:nil] cid:cid forMsgID:MIDDataTypeVisitorMsg];
}

//获取熟悉人面孔列表
-(void)reqFaceIDListForPerson:(NSString *)person_id cid:(NSString *)cid
{
    [JFGSDK sendUniversalData:[MPMessagePackWriter writeObject:@[cid,person_id] error:nil] cid:cid forMsgID:MIDDataTypeVisitorFaceList];
}

-(void)jfgOnUniversalData:(NSData *)msgData msgID:(int)mid seq:(long)seq
{
    if (![msgData isKindOfClass:[NSData class]]) {
        return;
    }
    id obj = [MPMessagePackReader readData:msgData error:nil];
    
    if (mid == MIDDataTypeVisitorList) {
        
        //访客列表
        //NSLog(@"mid:%d %@",mid,obj);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate msgForAIFamiliarPersons:personModelList total:total];
                });
                
                
            }
        });
        
        
        
    }else if (mid == MIDDataTypeStrangerList){
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
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
                                model.originImageUrl = person[1];
                                model.flag = [person[2] intValue];
                                model.last_time = [person[3] intValue];
                                model.faceImageUrl = [JFGSDK getCloudUrlWithFlag:model.flag fileName:model.originImageUrl];
                                
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
                dispatch_async(dispatch_get_main_queue(), ^{
                     [self.delegate msgForAIStranger:personModelList total:total];
                });
               
            }
        });
        
        //FLLog(@"陌生人总数:%d %@",total,personModelList);
        
    }else if (mid == MIDDataTypeVisitorCount){
        
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
        
    }else if (mid == MIDDataTypeVisitorMsg){
        
        //FLLog(@"%@",obj);
        NSMutableArray *resultArr = [NSMutableArray new];
        NSString *cid = @"";
        int type = 0;
        NSString *access_id = @"";
        NSArray *sourceObj1 = obj;
        if ([sourceObj1 isKindOfClass:[NSArray class]] && sourceObj1.count>4) {
            
            //cid, type, id, timeMsec, [dpdata1, dpdata2, ...
            cid = sourceObj1[0];
            type = [sourceObj1[1] intValue];
            access_id = sourceObj1[2];
            NSArray *dataArray = sourceObj1[4];
            if ([dataArray isKindOfClass:[NSArray class]]) {
    
                for (NSArray *data in dataArray) {
                    
                    if ([data isKindOfClass:[NSArray class]] && data.count>2) {
                        
                        int64_t timestamp = [data[1] longLongValue];
                        int msgID = [data[0] intValue];
                        MessageModel *messageModel = [[MessageModel alloc] init];
                        
                        
                        if (msgID == 505 || msgID == 512 || msgID == 526) {
                            
                            messageModel.msgID = 505;
                            messageModel.realyMsgID = msgID;
                            messageModel._version = timestamp;
                            
                            NSArray *values = [MPMessagePackReader readData:data[2] error:nil];
                            
                            messageModel.timestamp = [[values objectAtIndex:0] longLongValue];
                            messageModel.is_record = [[values objectAtIndex:1] boolValue];
                            messageModel.imageNum = [[values objectAtIndex:2] intValue];
                             messageModel.flag = [[values objectAtIndex:3] intValue];
                            if (values.count > 4) {
                                messageModel.objects = [self personPropertys:[values objectAtIndex:4]];
                            }else{
                                messageModel.objects = [NSMutableArray new];
                            }
                            messageModel.person_name = [self personNameFromPersons:messageModel.objects];
                            
                            if (values.count>8) {
                                NSArray *nameArr = values[8];
                                if ([nameArr isKindOfClass:[NSArray class]]) {
        
                                    NSString *nameStr = [nameArr componentsJoinedByString:@","];
                                    if (nameArr.count == 1) {
                                        nameStr = [nameArr componentsJoinedByString:@""];
                                    }
                                    messageModel.person_name = nameStr;
                                    
                                }
                                messageModel.objects = [NSMutableArray new];
                            }
                            
                            
                            if (msgID == 512) {
                                messageModel.deviceVersion = 3;
                            }else{
                                messageModel.deviceVersion = 2;
                            }
                            
                            [resultArr addObject:messageModel];
                            
                        }else if(msgID == 222){
                            
                            messageModel.msgID = 204;
                            messageModel.cid = cid;
                            messageModel.realyMsgID = msgID;
                            messageModel._version = timestamp;
                            messageModel.timestamp = timestamp/1000;
                            NSArray *values = [MPMessagePackReader readData:data[2] error:nil];
                            if (values && [values isKindOfClass:[NSArray class]]) {
                                
                                NSArray *objArr = values;
                                if (objArr.count >= 2) {
                                    id obj1 = [objArr objectAtIndex:0];
                                    id obj2 = [objArr objectAtIndex:1];
                                    if ([obj1 isKindOfClass:[NSNumber class]]) {
                                        messageModel.isSDCardOn = [obj1 boolValue];
                                    }
                                    if ([obj2 isKindOfClass:[NSNumber class]]) {
                                        messageModel.sdcardErrorCode = [obj2 intValue];
                                        if (messageModel.sdcardErrorCode != 0) {
                                            messageModel.isShowVideoBtn = YES;
                                        }else{
                                            messageModel.isShowVideoBtn = NO;
                                        }
                                    }
                                }
                            }
                            [resultArr addObject:messageModel];
                        }else if (msgID == 527){
                            
                            messageModel.msgID = 527;
                            messageModel.cid = cid;
                            messageModel.realyMsgID = msgID;
                            messageModel._version = timestamp;
                            messageModel.timestamp = timestamp/1000;
                            messageModel.otherMsg = @"";
                            //NSLog(@"527Msg:%@",data[2]);
                            if ([data[2] isKindOfClass:[NSData class]]) {
                                NSString *value = [MPMessagePackReader readData:data[2] error:nil];
                                if ([value isKindOfClass:[NSString class]]) {
                                    messageModel.otherMsg = value;
                                }
                            }else if ([data[2] isKindOfClass:[NSString class]]){
                                
                                NSString *name = data[2];
                               // NSLog(@"nameBefor:%@",name);
                                name = [name stringByReplacingOccurrencesOfString:@"�" withString:@""];
                                //NSLog(@"nameAfer:%@",name);
                                messageModel.otherMsg = name;
                                
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
        
    }else if (mid == MIDDataTypeDelVisitorMsg){
        
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
    }else if (mid == MIDDataTypeVisitorName){
        
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
        
    }else if (mid == MIDDataTypeVisitorFaceList){
        
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
        
    }else if (mid == MIDDataTypeRobotAddress){
        
        NSArray *objArr = obj;
        if ([objArr isKindOfClass:[NSArray class]] && objArr.count>1) {
            
            NSString *host = objArr[0];
            NSString *port = objArr[1];
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgForRobotHost:post:)]) {
                [self.delegate msgForRobotHost:host post:port];
            }
        }
        
    }else if (mid == MIDDataTypeVisitorCountEx){
        
        NSArray *objArr = obj;
        if ([objArr isKindOfClass:[NSArray class]] && objArr.count>4) {
            NSString *cid = objArr[0];
            int start = [objArr[2] intValue];
            int end = [objArr[3] intValue];
            NSArray *vis = objArr[5];
            NSMutableArray *visModels = [NSMutableArray new];
            if ([vis isKindOfClass:[NSArray class]]) {
                
                for (id visObj in vis) {
                    
                    NSArray *visOj = visObj;
                    if ([visOj isKindOfClass:[NSArray class]] && visOj.count>1) {
                        
                        int time = [visOj[0] intValue];
                        int count = [visOj[1] intValue];
                        visitCountModel *model = [visitCountModel new];
                        model.startTimestamp = time;
                        model.visitCount = count;
                        [visModels addObject:model];
                        
                    }
                    
                }
                
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgForAIVisitCountForCid:startTime:endTime:visitModel:)]) {
                [self.delegate msgForAIVisitCountForCid:cid startTime:start endTime:end visitModel:visModels];
            }
        }
        
    }
}

//人物属性转化为人脸属性数据模型
-(NSArray *)personPropertys:(NSArray *)objs
{
    NSMutableArray *newArr = [NSMutableArray new];
    if ([objs isKindOfClass:[NSArray class]]) {
        
        for (NSArray *personObjs in objs) {
            
            if ([personObjs isKindOfClass:[NSArray class]] && personObjs.count>2) {
                
                /*
                 "MESSAGES_GENDER_MALE" = "男";
                 "MESSAGES_GENDER_FEMALE" = "女";
                 "MESSAGES_AGE" = "%@岁";
                 */
                faceProperty *face = [faceProperty new];
                face.name = personObjs[0];
                face.sex = personObjs[1];
                face.age = personObjs[2];
                
                //保证数据不为nil
                if (![face.name isKindOfClass:[NSString class]]) {
                    face.name = @"";
                }
                
                if ([face.sex isKindOfClass:[NSString class]] && ![face.sex isEqualToString:@""]) {
                    
                    if ([face.sex isEqualToString:@"male"]) {
                        face.sex = [JfgLanguage getLanTextStrByKey:@"MESSAGES_GENDER_MALE"];
                    }else{
                        face.sex = [JfgLanguage getLanTextStrByKey:@"MESSAGES_GENDER_FEMALE"];
                    }
                }else{
                    face.sex = @"";
                }
                
                if ([face.age isKindOfClass:[NSString class]] && ![face.age isEqualToString:@""]) {
                    
                    int age = [face.age intValue];
                    face.age = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_AGE"],[NSString stringWithFormat:@"%d",age]];
                    
                }else{
                    face.age = @"";
                }
                
                [newArr addObject:face];
                
            }
            
        }
    }
    return newArr;
}


//人脸属性数据模型组合成多语言字符串
-(NSString *)personNameFromPersons:(NSArray *)pers
{
    if (pers.count) {
        NSMutableString *personName = [NSMutableString new];
        for (faceProperty *face in pers) {
            
            if ([face isKindOfClass:[faceProperty class]]) {
            
                if ([face.name isEqualToString:@""]) {
                    
                    NSString *pers = @"";
                    if ([face.sex isEqualToString:@""] && [face.age isEqualToString:@""]) {
                        pers = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_STRANGER"];
                    }else if ([face.age isEqualToString:@""]){
                        pers = [NSString stringWithFormat:@"%@(%@)",[JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_STRANGER"],face.sex];
                    }else if([face.sex isEqualToString:@""]){
                        pers = [NSString stringWithFormat:@"%@(%@)",[JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_STRANGER"],face.age];
                    }else{
                        pers = [NSString stringWithFormat:@"%@(%@,%@)",[JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_STRANGER"],face.sex,face.age];
                    }
                    
                    if (![personName isEqualToString:@""]) {
                        [personName appendString:[NSString stringWithFormat:@",%@",pers]];
                    }else{
                        [personName appendString:pers];
                    }
                    
                }else if([face.sex isEqualToString:@""] || [face.age isEqualToString:@""]) {
                    
                    NSString *pers = face.name;
                    if ([face.sex isEqualToString:@""] && ![face.age isEqualToString:@""]) {
                        
                        pers = pers = [NSString stringWithFormat:@"%@(%@)",face.name,face.age];
                        
                    }else if(![face.sex isEqualToString:@""] && [face.age isEqualToString:@""]){
                        pers = pers = [NSString stringWithFormat:@"%@(%@)",face.name,face.sex];
                    }
                
                    if (![personName isEqualToString:@""]) {
                        [personName appendString:[NSString stringWithFormat:@",%@",pers]];
                    }else{
                        [personName appendString:pers];
                    }
                    
                }else{
                    
                    NSString *pers = [NSString stringWithFormat:@"%@(%@,%@)",face.name,face.sex,face.age];
                    if (![personName isEqualToString:@""]) {
                        [personName appendString:[NSString stringWithFormat:@",%@",pers]];
                    }else{
                        [personName appendString:pers];
                    }
                }
                
                
            }
        }
        return personName;
        
    }else{
        return @"";
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

@implementation  visitCountModel

@end

