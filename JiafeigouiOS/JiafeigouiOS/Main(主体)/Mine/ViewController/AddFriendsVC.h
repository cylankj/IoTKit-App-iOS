//
//  AddFriendsVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseFriendsVC.h"

@interface AddFriendsVC : BaseFriendsVC<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, retain)NSArray * frindsArr;

@end
