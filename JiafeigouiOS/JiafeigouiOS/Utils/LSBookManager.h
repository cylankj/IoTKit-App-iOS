//
//  LSBookManager.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSBookManager : NSObject
+ (LSBookManager *)sharedManager;
-(NSString*)getPlistPath;
-(BOOL) isPlistFileExists;
-(void)initPlist;
-(NSMutableArray*)readPlist;
-(void)deletePlist;
-(void)writePlist:(NSMutableDictionary *)dic;
@end
