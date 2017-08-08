//
//  AIRecognitionVIewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"
#import "tableViewDelegate.h"

NSString *const titleKey = @"_title";
NSString *const normalImageKey = @"_normalimageName";
NSString *const selectedImageKey = @"_selectedImage";
NSString *const isSelectedItemKey = @"_isSelectedItem";
NSString *const aiTypeKey = @"_aiType";

@interface AIRecognitionVIewModel : BaseViewModel<tableViewDelegate>

@property (nonatomic, assign) id<tableViewDelegate> delegate;

- (void)requestFromServer;

- (void)selectedItem:(NSInteger)aiType;

- (NSArray *)aiRecgnitions;

@end
