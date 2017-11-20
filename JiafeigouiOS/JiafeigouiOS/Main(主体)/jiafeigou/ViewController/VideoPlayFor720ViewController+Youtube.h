//
//  VideoPlayFor720ViewController+Youtube.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "VideoPlayFor720ViewController.h"

@interface VideoPlayFor720ViewController (Youtube)

@property (nonatomic,strong)YoutubeLiveStreamsModel *youtubeModel;

-(void)startYoutubeLive;
-(void)stopYoutubeReq;

@end
