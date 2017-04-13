//
//  Watch720PhotoVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

/*
    720 视频 和 照片 共用VC
 */

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, MediaType) {
    mediaTypeVideo,
    mediaTypePhoto
};

@interface Watch720PhotoVC : BaseViewController

@property (nonatomic, assign) MediaType mediaType;

@property (nonatomic, copy) NSString *panoMediaPath;

@end
