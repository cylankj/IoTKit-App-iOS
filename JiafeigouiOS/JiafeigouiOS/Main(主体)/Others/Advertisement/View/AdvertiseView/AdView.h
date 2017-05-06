//
//  AdView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/5/4.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdDelegate <NSObject>

- (void)skipAction;

- (void)watchAd:(NSString *)adUrlString;

@end

@interface AdView : UIView

@property (nonatomic, assign) id<AdDelegate> delegate;

@end
