//
//  PickerEditImageViewController.h
//  GestureRecognizerDemoi
//
//  Created by 杨利 on 16/8/2.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PickerEditImageSourceType){
    
    PickerEditImageSourceTypePhotoLibrary,
    PickerEditImageSourceTypeCamera,
    
};

@interface PickerEditImageViewController : UIViewController

@property (nonatomic,assign)PickerEditImageSourceType sourceType;
@property (nonatomic,strong)UIImage *image;

@end
