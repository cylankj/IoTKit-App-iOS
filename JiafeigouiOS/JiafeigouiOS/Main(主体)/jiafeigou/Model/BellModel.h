//
//  BellModel.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseModel.h"

@interface BellModel : BaseModel

//日期
@property (copy, nonatomic)     NSString * bellDate;
//时间
@property (copy, nonatomic)     NSString * bellTime;

@property (assign,nonatomic)int flag;
@property (copy,nonatomic)NSString *fileName;
@property (assign,nonatomic)int64_t timestamp;

@property (copy,nonatomic) NSString *headUrl;

@property (nonatomic,assign)int deviceVersion;

//是否接听
@property (assign, nonatomic)   BOOL isAnswered;
//是否被选中
@property (assign, nonatomic)   BOOL isSelected;
@end
