//
//  SecurityCodeButton.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KeepTimeFinished)(void);

@interface SecurityCodeButton : UIButton

//开始倒计时
-(void)startKeepTime;

//倒计时结束回调
@property (nonatomic,assign)KeepTimeFinished  keepTimeFinished;

@property (nonatomic,assign)BOOL isKeepTimeing;

@end
