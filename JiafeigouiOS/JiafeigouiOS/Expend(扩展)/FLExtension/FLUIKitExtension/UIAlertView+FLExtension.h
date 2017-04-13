//
//  UIAlertView+FLExtension.h
//  FLExtensionTask
//
//  Created by 紫贝壳 on 15/8/14.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (FLExtension)

/**
 *用Block的方式回调代理(alertView: clickedButtonAtIndex:)方法,如果还需要执行其他的代理方法请设置delegate,并遵守协议<UIAlertDelegate>
 */
- (void)showAlertViewWithClickedButtonBlock:(void(^)(NSInteger buttonIndex))block
                              otherDelegate:(id)delegate;


@end
