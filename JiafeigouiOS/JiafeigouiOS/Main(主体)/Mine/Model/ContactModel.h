//
//  ContactModel.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    contactTypeAddressBook,//从通讯录中获取的
    contactTypeShared,//从服务器下发的共享列表
}contactType;
@interface ContactModel : NSObject
@property(nonatomic, assign)contactType type;
@property(nonatomic, copy)NSString * name;
@property(nonatomic, copy)NSString * phoneNum;
@property(nonatomic, copy)NSString * email;
@property(nonatomic, assign)BOOL isShared;
@property(nonatomic, assign)BOOL isAdded;
@property(nonatomic, assign)BOOL isRegiter;
@end
