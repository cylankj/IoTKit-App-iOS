//
//  SearchView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol searchViewDelegate <NSObject>

- (void)didClickedCancelButton:(UIButton *)cancelButton;

@end

@interface SearchView : UIView<UITextFieldDelegate>

@property (assign, nonatomic) id<searchViewDelegate> searchDelegate;

@property (strong, nonatomic) UILabel *tipLabel; // 搜索文字 那个Label

@property (strong, nonatomic) UITextField *searchTextField;

@property (assign, nonatomic) BOOL showCancelButton; //Default YES if it is NO, it will be not animated

@end
