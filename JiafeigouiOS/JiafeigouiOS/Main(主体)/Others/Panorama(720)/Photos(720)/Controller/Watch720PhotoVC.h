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
#import "Pano720PhotoModel.h"

typedef NS_ENUM(NSInteger, MediaType) {
    mediaTypeVideo,
    mediaTypePhoto
};

typedef NS_ENUM(NSInteger, SourceType) {
    SourceTypeDevicePhoto,  // 设备 相册 照片
    SourceTypeMSGPhoto,     // 报警 消息 照片
};

@protocol watchPhotoDelegate <NSObject>

@optional
- (void)donwloadWithModel:(Pano720PhotoModel *)model;
- (void)deleteModelInLocal:(Pano720PhotoModel *)model;

@end


@interface Watch720PhotoVC : BaseViewController

@property (nonatomic, assign) MediaType panoMediaType;
@property (nonatomic, strong) Pano720PhotoModel *panoModel;
@property (nonatomic, assign) id<watchPhotoDelegate> myDelegate;

@property (nonatomic, assign) FileExistType existType;

@property (nonatomic, strong) UIImage *thumbNailImage;
@property (nonatomic, assign) long long titleTime;          // Time Tiltle
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *panoMediaPath;

@property (nonatomic, assign) SourceType originType;


@end
