//
//  AIRecognitionModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AIRecognitionModel.h"
#import "JfgTypeDefine.h"
#import "JfgDataTool.h"

@implementation AIRecognitionModel

- (NSString *)aiRecognitionStr
{
    return [JfgDataTool aiRecognitionStr:self.aiRecognitions];
}

- (NSMutableArray *)aiRecognitions
{
    if (_aiRecognitions == nil)
    {
        _aiRecognitions = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _aiRecognitions;
}



@end
