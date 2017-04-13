//
//  MessageImageView.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageImageView : UIImageView

@property (nonatomic, copy)NSString * url;
@property (copy,nonatomic)NSString *fileName;
@property (copy,nonatomic)NSString *cid;
@property (assign,nonatomic)BOOL isPanorama;
@property (assign,nonatomic)int deviceVersion;
@property (assign,nonatomic)int regionType;
@property (assign,nonatomic)int tly;
@end
