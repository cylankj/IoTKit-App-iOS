//
//  JFGWebViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef NS_ENUM(NSInteger,webViewType){
    webViewTypeJFG = 0,
    webViewTypeUserProtocol,
    webViewTypePhone,
    webViewTypeAd
};
@interface JFGWebViewController : BaseViewController
@property(nonatomic, assign)webViewType type;
@property(nonatomic, copy)NSString * urlString;
@end
