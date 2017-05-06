//
//  LSChatModel.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "LSChatModel.h"
#import "LSBookManager.h"
#import "FLGlobal.h"

@interface LSChatModel ()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end


@implementation LSChatModel

/** 获取全部的聊天数据*/
+ (NSArray<LSChatModel *> *)allMsgModel{
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    //获取plist
    NSArray * plistArr = [[LSBookManager sharedManager] readPlist];
    for (NSDictionary * obj in plistArr) {
        LSChatModel * mod = [[LSChatModel alloc]init];
        //利用KVC生成Dic对应的model
        [mod setValuesForKeysWithDictionary:obj];
        [array addObject:mod];
    }
    return array;
    
}

#pragma mark - 一系列set方法

+ (LSChatModel *)creatModel:(NSDictionary *)dic{
    
    LSChatModel *aModel =[[LSChatModel alloc] init];
    
    aModel.msg =[dic objectForKey:@"msg"];
    aModel.msgDate =[dic objectForKey:@"msgDate"];
    aModel.lastMsgDate =[dic objectForKey:@"lastMsgDate"];
    if ([[dic objectForKey:@"modelType"] boolValue]) {
        aModel.modelType =LSModelTypeMe;
    }else{
        aModel.modelType =LSModelTypeOther;
    }
    
    return aModel;
}

- (void)setMsg:(NSString *)msg{
    _msg =[msg copy];

}

- (void)setLastMsgDate:(NSString *)lastMsgDate{
    _lastMsgDate =[lastMsgDate copy];
    
    if (!self.lastMsgDate) {
        self.enableDateLabel = YES;
        self.cellHeight =[self getMsgHeight:self.msg] +12;
    }
    
    if ([self.lastMsgDate isEqualToString:self.msgDate]) {
        self.enableDateLabel = NO;
        self.cellHeight =[self getMsgHeight:self.msg];
    }else{
        self.enableDateLabel = YES;
        self.cellHeight =[self getMsgHeight:self.msg] +12;
    }
    
}

- (CGFloat)cellHeight{
    
    return _cellHeight;
    
    
}

- (void)setModelType:(LSModelType)modelType{
    _modelType =modelType;
}


- (NSDateFormatter *)formatter{
    
    if (!_formatter) {
        _formatter =[[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy/MM/dd hh:mm"];
    }
    
    return _formatter;
    
}


- (CGFloat)getMsgHeight:(NSString *)msg{
    CGSize textMaxSize=CGSizeMake(250*designWscale, MAXFLOAT);
    NSDictionary *attr1=@{NSFontAttributeName:[UIFont systemFontOfSize:18]};
    return [msg boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr1 context:nil].size.height;
}


@end
