//
//  JFGMsgRobotForwardDataModel.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFGMsgRobotForwardDataModel : NSObject

@property (nonatomic,copy)NSString *cid;
@property (nonatomic,copy)NSString *fileName;
@property (nonatomic,copy)NSString *md5;
@property (nonatomic,assign)int fileSize;
@property (nonatomic,assign)int currentFileLength;
@property (nonatomic,strong)NSMutableData *fileData;

@end
