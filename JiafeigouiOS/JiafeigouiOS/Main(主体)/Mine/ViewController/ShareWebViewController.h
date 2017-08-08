//
//  ShareWebViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/24.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"

@protocol  ShareWebVCDelegate<NSObject>

-(void)didDelShareContentForVersion:(uint64_t)version;

@end

@interface ShareWebViewController : JFGBaseViewController

@property (nonatomic,strong)UIImage *thumdImage;
@property (nonatomic,copy)NSString *h5Url;
@property (nonatomic,assign)uint64_t version;
@property (nonatomic,weak)id<ShareWebVCDelegate>delegate;

@end
