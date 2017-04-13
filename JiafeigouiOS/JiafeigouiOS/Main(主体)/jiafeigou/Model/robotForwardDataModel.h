//
//  robotForwardDataModel.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface robotForwardDataModel : NSObject

@end


@interface MsgTypeTakePhotoRsp : NSObject

@property (nonatomic,assign)int ret;
@property (nonatomic,copy)NSString *fileName;
@property (nonatomic,assign)int fileSize;
@property (nonatomic,copy)NSString *md5;

@end
