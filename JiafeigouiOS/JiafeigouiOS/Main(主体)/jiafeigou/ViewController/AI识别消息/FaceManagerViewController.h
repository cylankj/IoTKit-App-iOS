//
//  FaceManagerViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"
#import "MsgForAIModel.h"

@interface FaceManagerViewController : JFGBaseViewController

@property (nonatomic,copy)NSString *cid;
@property (nonatomic,strong)MsgAIheaderModel *msgModel;

@end

@interface FaceManagerDataModel : NSObject

@property (nonatomic,assign)BOOL isSelected;
@property (nonatomic,copy)NSString *face_id;
@property (nonatomic,copy)NSString *faceImageUrl;

@end
