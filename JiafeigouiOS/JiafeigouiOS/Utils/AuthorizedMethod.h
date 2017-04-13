//
//  AuthorizedMethod.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthorizedMethod : NSObject
+ (BOOL)isAdressBookAuthorized;
+ (BOOL)isCameraAuthorized;
+ (BOOL)isMikeAuthorized;
+ (BOOL)isPhotosAuthorized;

+ (BOOL)isOpenSystemNotification;

@end
