//
//  SysMsgViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/9/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFGBaseViewController.h"

typedef NS_ENUM(NSInteger,SysMsgType){
    
    SysMsgTypeBind = 0,//绑定消息
    SysMsgTypeServer = 1,//服务器消息
    
};

@interface SysMsgViewController : JFGBaseViewController

@end


@interface SysMsgModel : NSObject

@property (nonatomic,assign)SysMsgType msgType;
@property (nonatomic,copy)NSString *msg;
@property (nonatomic,copy)NSString *cid;
@property (nonatomic,copy)NSString *bindAccount;
@property (nonatomic,assign)int64_t timestamp;
@property (nonatomic,assign)BOOL isBinded;
@property (nonatomic,assign)BOOL isDelSelected;
@property (nonatomic,assign)CGFloat cellHeight;

@end
