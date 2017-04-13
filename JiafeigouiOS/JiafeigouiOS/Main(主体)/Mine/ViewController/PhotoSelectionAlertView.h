//
//  PhotoSelectionAlertView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/7/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PhotoSelectionAlertViewDelegate;

@interface PhotoSelectionAlertView : UIView

-(instancetype)initWithMark:(NSString *)mark
                   delegate:(id<PhotoSelectionAlertViewDelegate>)delegate
          otherButtonTitles:(NSString *)otherButtonTitles, ...;

-(void)show;

@end




@protocol PhotoSelectionAlertViewDelegate <NSObject>

@optional

- (void)actionSheet:(PhotoSelectionAlertView *)actionSheet
               mark:(NSString *)mark
clickedButtonAtIndex:(NSInteger)buttonIndex;


@end