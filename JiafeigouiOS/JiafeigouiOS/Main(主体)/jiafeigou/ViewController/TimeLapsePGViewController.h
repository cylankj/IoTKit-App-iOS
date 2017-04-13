//
//  TimeLapsePGViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum cameraState
{
    cameraStatePreparing,
    cameraStateWaitting,
    cameraStateShooting,
    cameraStatePause,
    cameraStateHandling,
    cameraStateEnd,
    cameraStateFailed,
    cameraStateNoNet,
}cameraState;
@interface TimeLapsePGViewController : UIViewController
//摄像头状态
@property(assign, nonatomic)cameraState state;
//摄像头cid
@property(copy, nonatomic)NSString * cid;
@end
