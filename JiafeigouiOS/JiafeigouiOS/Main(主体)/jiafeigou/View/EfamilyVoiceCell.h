//
//  EfamilyVoiceCell.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseEfamilyCell.h"

@interface EfamilyVoiceCell : BaseEfamilyCell

/**
 *  音频 时长 Label
 */
@property (nonatomic, retain) UILabel *voiceDuraLabel;
/**
 *  音波 图片
 */
@property (nonatomic, retain) UIImageView *voiceImageView;
/**
 *  loading 图片
 */
@property(nonatomic, retain) UIImageView *loadingImageView;


@end
