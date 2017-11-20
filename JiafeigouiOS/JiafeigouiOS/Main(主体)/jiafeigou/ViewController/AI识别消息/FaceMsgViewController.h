//
//  FaceMsgViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"
#import "MsgForAIModel.h"

@interface FaceMsgViewController : JFGBaseViewController

@property (nonatomic,copy)NSString *person_id;
@property (nonatomic,copy)NSString *cid;
@property (nonatomic,copy)NSString *person_name;
@property (nonatomic,copy)NSString *headImageUrl;
@property (nonatomic,strong)NSArray *faceList;
@property (nonatomic,strong)MsgAIheaderModel *msgModel;

@end
