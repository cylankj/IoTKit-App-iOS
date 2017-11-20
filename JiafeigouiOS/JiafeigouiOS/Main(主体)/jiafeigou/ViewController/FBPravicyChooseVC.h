//
//  FBPravicyChooseVC.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/14.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"


@protocol FBPravicyChooseDelegate <NSObject>

-(void)didChooseForType:(NSString *)type;

@end


@interface FBPravicyChooseVC : JFGBaseViewController


@property (nonatomic,weak)id <FBPravicyChooseDelegate> delegate;

@end



@interface FBGroupModel : NSObject

@property (nonatomic,copy)NSString *groupID;
@property (nonatomic,copy)NSString *groupName;
@property (nonatomic,copy)NSString *groupPrivacy;

@end

