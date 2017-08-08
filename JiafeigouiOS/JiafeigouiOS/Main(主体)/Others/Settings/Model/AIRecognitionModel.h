//
//  AIRecognitionModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseModel.h"

@interface AIRecognitionModel : BaseModel

@property (strong, nonatomic)NSMutableArray *aiRecognitions;
@property (copy, nonatomic) NSString *aiRecognitionStr;

@end
