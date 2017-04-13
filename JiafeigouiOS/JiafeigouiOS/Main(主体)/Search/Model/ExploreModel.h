//
//  ExploreModel.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/9/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseModel.h"

@interface ExploreModel : BaseModel

//每天动态的显示时间
@property (copy, nonatomic)NSString * time;
//每一条消息生成的时间
@property (copy, nonatomic)NSString * msgTime;
//是否是图片
@property (assign, nonatomic)BOOL isPic;
@property (assign,nonatomic)int regionType;
//@property (copy,nonatomic)NSString *cid;
//图片
@property (copy, nonatomic)NSString * url;
//视频URL
@property (copy,nonatomic) NSString *videoUrl;
@property (copy, nonatomic)NSString *alias;
@property (nonatomic,assign)int64_t collectedTimestamp;

@end
