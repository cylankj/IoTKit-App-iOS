//
//  MagViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, MagState){
    magStateClose = 0,
    magStateOpen = 1,
    magStateOffline = 2,
};

@interface MagViewController : UIViewController

//@property(assign, nonatomic)MagState magState;

@property(copy, nonatomic)NSString * cid;

@property (assign, nonatomic) BOOL isShare;

@end

@interface MenciModel : NSObject

@property (nonatomic,assign)BOOL isOpen;//是否打开
@property (nonatomic,assign)int64_t timestamp;//时间戳

@end
