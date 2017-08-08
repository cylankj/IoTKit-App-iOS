//
//  AIRecognitionVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol AIRecognitionDelegate <NSObject>

- (void)updateAIRecognition:(NSArray *)aiTypes;

@end

@interface AIRecognitionVC : BaseViewController

@property (nonatomic, assign) id<AIRecognitionDelegate> delegate;

@end
