//
//  WifiListView.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JFGSDK/JFGSDKBindingDevice.h>

@interface WifiListView : UIView


typedef NS_ENUM(NSInteger,WifiListType) {
    
    WifiListTypeWifiName,
    WifiListTypeCid,
    
};


@property (nonatomic,assign)WifiListType listType;

-(instancetype)initWithFrame:(CGRect)frame withType:(WifiListType)type;
+(void)createWifiListViewForType:(WifiListType)type commplete:(void (^) (id obj))selectedBlock;
-(void)closeWifiListAction;

@end
@interface WifiCoverView : UIView

@end
