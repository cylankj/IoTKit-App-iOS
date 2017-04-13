//
//  SearchFriendsView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsSearchBar.h"
@interface SearchFriendsView : UIView

@property (nonatomic, strong) FriendsSearchBar *searchBar;

- (void)animationToTop;
- (void)animationToBottom;

@end
