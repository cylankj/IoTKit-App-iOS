//
//  WifiListView.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WifiListView : UIView
-(instancetype)initWithFrame:(CGRect)frame;
+(void)createWifiListView:(void (^) (NSString *wifiNameString))selectedBlock;
-(void)closeWifiListAction;

@end
@interface WifiCoverView : UIView

@end
