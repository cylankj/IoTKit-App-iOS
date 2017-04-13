//
//  FriendsSearchBar.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/4.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseColourView.h"

@protocol FriendsSearchDelegate <NSObject>

- (void)didClickedCancelButton:(UIButton *)cancelButton;

@end

@interface FriendsSearchBar : BaseColourView

@property (nonatomic, strong) UITextField *searchField;

@property (nonatomic, assign) id<FriendsSearchDelegate> searchDelegate;

@end
