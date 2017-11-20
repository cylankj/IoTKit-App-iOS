//
//  FaceAddressBookVC.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"

@protocol FaceAddressBookVCDelegate <NSObject>


-(void)faceAddressSelectedPersonForIndex:(NSIndexPath *)indexPath;

@end

@interface FaceAddressBookVC : JFGBaseViewController

@property (nonatomic,copy)NSString *cid;
@property (nonatomic,copy)NSString *face_id;
@property (nonatomic,copy)NSString *person_id;//如果有，则传入
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic,weak)id <FaceAddressBookVCDelegate> delegate;

@end

