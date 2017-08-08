//
//  PickerGroupViewController.h
//  PhotoPickerDemo
//
//  Created by 杨利 on 16/7/30.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFGBaseViewController.h"
@protocol PickerGroupViewControllerDelegate;

@interface PickerGroupViewController : JFGBaseViewController

@property (nonatomic,weak)id <PickerGroupViewControllerDelegate> delegate;

@end

@protocol PickerGroupViewControllerDelegate <NSObject>

-(void)pickerEditFinishedImage:(UIImage *)image;

-(void)cancel;

@end
