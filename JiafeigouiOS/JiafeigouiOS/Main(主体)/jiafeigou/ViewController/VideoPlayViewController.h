//
//  VideoPlayViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "videoPlay1ViewController.h"

@interface VideoPlayViewController : UIViewController

@property (nonatomic,copy)NSString *cid;

@property (nonatomic,strong)JiafeigouDevStatuModel *devModel;

/* isOffset YES 偏移   消息页面
            NO 不偏移  视频页面
*/
- (void)setInnerScrollViewContentOffset:(BOOL)isOffset;

@end
