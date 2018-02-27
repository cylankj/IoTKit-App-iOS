//
//  MsgForAIModel.h
//  JiafeigouiOS
//
//  Created by yangli on 2017/10/25.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,AIModelType) {
    
    AIModelTypeAll,//全部按钮
    AIModelTypeUnknow,//陌生人按钮
    AIModelTypeAddFace,//增加人脸按钮
    AIModelTypeUnRegister,//未注册人脸
    AIModelTypeRegister,//已注册人脸
    //AIModelTypeCat,//猫
    //AIModelTypeDog,//狗
    //AIModelTypeCar,//车
    
};

@interface StrangerModel : NSObject

@property (nonatomic,copy)NSString *face_id;
@property (nonatomic,copy)NSString *faceImageUrl;
@property (nonatomic,assign)int last_time;
@property (nonatomic,assign)int flag;
@property (nonatomic,copy)NSString *originImageUrl;

@end

@interface FamiliarPersonsModel : NSObject

@property (nonatomic,assign)int total;            // 已注册人物总数
@property (nonatomic,assign)int object_type;       // 检测到的物体类型
@property (nonatomic,copy)NSString *person_id;        // 已注册人物id
@property (nonatomic,copy)NSString *person_name;       // 已注册人物名称
@property (nonatomic,assign)int last_time;        // 最后访问时间，单位：秒
@property (nonatomic,strong)NSArray *face_id;          // 人物面孔唯一标识
@property (nonatomic,strong)NSArray <StrangerModel *> *strangerArr;
@end

@interface MsgAIheaderModel : NSObject

@property (nonatomic,assign)AIModelType type;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *person_id;
@property (nonatomic,strong)NSArray *faceIDList;// 人物面孔标识
@property (nonatomic,strong)NSArray <StrangerModel *>*faceMsgList;
@property (nonatomic,copy)NSString *faceImageUrl;
@property (nonatomic,assign)int64_t last_time;// 最后访问时间，单位：秒
@property (nonatomic,assign)int object_type;// 检测到的物体类型
@property (nonatomic,assign)int visitCount;//-1表示未赋值，大于等于0，表示已经赋值
@property (nonatomic,copy)NSString *originImageUrl;
@property (nonatomic,assign)int flag;

@end


@interface MsgForAIModel : NSObject

@end
