//
//  EfamilyRootVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EfamilyRootViewModel.h"
#import "FLProressHUD.h"

typedef NS_ENUM(NSUInteger, cellType)
{
    cellTypeLeaveMsg, // 语音 留言
    cellTypeClientCall, // 客户端 呼叫
    cellTypeEfamilyCall, // 中控 呼叫
};


@interface EfamilyRootVC : BaseViewController<UITableViewDelegate, UITableViewDataSource, efamilyRootDelegate>

@end
