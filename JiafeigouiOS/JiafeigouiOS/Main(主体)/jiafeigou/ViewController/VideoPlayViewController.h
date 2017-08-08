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

//首次出现消息界面，使用此方法初始化
-(instancetype)initWithMessage;

/* isOffset YES 偏移   消息页面
            NO 不偏移  视频页面
 
 废弃  外部调用此方法，导致方法里面的视图执行先于viewDidload，出现视图显示问题
*/
- (void)setInnerScrollViewContentOffset;

@end
