//
//  JFGTimepieceView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JFGTimepieceView : UIView

-(void)startTimerForHour:(int)_hour min:(int)_min sec:(int)_sec;
-(void)stopTimer;

@end
