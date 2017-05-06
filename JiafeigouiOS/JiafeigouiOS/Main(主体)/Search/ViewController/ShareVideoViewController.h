//
//  ShareVideoViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/4.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFGBaseViewController.h"
#import <ShareSDK/ShareSDK.h>

typedef NS_ENUM(NSInteger,ShareFileType){
    ShareFileTypePic,
    ShareFileTypeVideo,
};

@interface ShareVideoViewController : JFGBaseViewController

//以下参数必填
@property (nonatomic,copy)NSString *cid;//设备cid
@property (nonatomic,copy)NSString *devAlias;//设备昵称
@property (nonatomic,copy)NSString *filePath;//文件路径
@property (nonatomic,strong)UIImage *thumbImage;//缩略图
@property (nonatomic,assign)SSDKPlatformType platformType;//分享平台
@property (nonatomic,assign)ShareFileType fileType;//分享内容类型

@end
