//
//  FaceCreateViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"
#import "JiafeigouDevStatuModel.h"

@protocol FaceCreateVCDelegate <NSObject>

-(void)faceCreateSuccessForIndex:(NSIndexPath *)indexPath;

@end

@interface FaceCreateViewController : JFGBaseViewController

@property (nonatomic,weak)id <FaceCreateVCDelegate> delegate;
@property (nonatomic,copy)NSString *cid;
@property (nonatomic,copy)NSString *access_id;
@property (nonatomic,copy)NSString *headImageUrl;
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;

@end
