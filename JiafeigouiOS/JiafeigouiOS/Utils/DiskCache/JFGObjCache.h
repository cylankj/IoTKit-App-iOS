//
//  JFGObjCache.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFGObjCache : NSObject

+(void)saveObjs:(NSArray *)objList toPath:(NSString *)path;

+(NSArray *)achieveClass:(Class)_class byPath:(NSString *)path;

@end
