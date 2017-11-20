//
//  MsgAIHeadPortraitView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgForAIRequest.h"
#import "MsgForAIModel.h"

@protocol MsgAIHeadPortraitViewDelegate <NSObject>

//高度变化
-(void)msgAIHeadPortraitViewHeightChanged:(CGFloat)height;
-(void)msgAIHeadPortraitViewDidUnkonwItemHasData:(BOOL)hasData;
-(void)msgAIHeadPortraitViewDidSelectedCellForModel:(MsgAIheaderModel *)model;
-(void)msgAIHeadPortraitViewDelModel:(MsgAIheaderModel *)model isReloadModel:(MsgAIheaderModel *)reloadModel;

@end

@interface MsgAIHeadPortraitView : UIView

@property (nonatomic,copy)NSString *cid;
@property (nonatomic,assign)BOOL isFamilyshow;//是否展示的是标定过的人
@property (nonatomic,weak) id <MsgAIHeadPortraitViewDelegate> delegate;
@property (nonatomic,readonly)NSMutableArray *familyArray;//熟人
@property (nonatomic,readonly)NSMutableArray *unKnowArray;//陌生人

-(instancetype)initWithFrame:(CGRect)frame cid:(NSString *)cid;
//返回熟人列表
-(void)backFamily;
//更新数据
-(void)reqData;
//有新的推送消息产生
-(void)hasNewMsgNotification;
//缓存数据
-(void)cacheHeaderData;

@end



