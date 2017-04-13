//
//  DJActionRuler.h
//  DJActionRuler
//
//  Created by SghOmk on 16/6/27.
//  Copyright © 2016年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@class DJActionRuler,DJActionRulerTabView;

@protocol DJActionRulerDelegate <NSObject>

@optional
/**
 *	@author dingjiong, 16-06-28
 *
 *	滚动过程中,需要显示的时间
 *	@param actionRuler	DJActionRuler
 *	@param aDateString	将要选中的时间字符串yyyMMddhhmmss
 *	@since 1.0
 */
-(void)actionRuler:(DJActionRuler *)actionRuler willSelectedDateString:(NSString *)aDateString;
/**
 *	@author dingjiong, 16-06-28
 *
 *	停止滚动 (最终选中的时间)
 *	@param actionRuler	DJActionRuler
 *	@param aDateString	最终选中的时间字符串yyyMMddhhmmss
 *	@since <#1.0#>
 */
-(void)actionRuler:(DJActionRuler *)actionRuler didSelectedDateString:(NSString *)aDateString;

@end

@interface DJActionRuler : UIView
/**
 *	@author dingjiong, 16-06-28
 *
 *	代理对象
 *	@since 1.0
 */
@property (assign, nonatomic)                   id<DJActionRulerDelegate>rulerDelegate;
/**
 *	@author dingjiong, 16-06-28
 *
 *	加载时间,并让刻度停靠在相应的位置,每次更新数组之后都可可以调用次方法(相当于UITableView的reloadData)
 *	@param array        有数据的时间数组
 *	@param dateString	刻度尺需要停靠的时间
 *	@since 1.0
 */
- (void)loadDateStringArray:(NSMutableArray *)array markedDateString:(NSString *)dateString;


-(void)scrollToRowForDate:(NSDate *)date;

@end

/**
 *	@author dingjiong, 16-06-28
 *
 *	这是重写的UITableView  self.transform =CGAffineTransformMakeRotation(- M_PI /2);
 *	@since 1.0
 */
@interface DJActionRulerTabView : UITableView


@end

/**
 *	@author dingjiong, 16-06-28
 *
 *	这是重写的cell [self setTransform:CGAffineTransformMakeRotation(M_PI /2)];
 *	@since
 */
@interface DJActionRulerCell : UITableViewCell
/**
 *	@author dingjiong, 16-06-28
 *
 *	上面显示月中月初的label
 *	@since 1.0
 */
@property (retain ,nonatomic)                   UILabel *titleLabel;
/**
 *	@author dingjiong, 16-06-28
 *
 *	是否标记为有数据
 *	@since 1.0
 */
@property (assign ,nonatomic)                   BOOL isMark;
/**
 *	@author dingjiong, 16-06-28
 *
 *	是否是长线条 (月中月初为长线条)
 *	@since 1.0
 */
@property (assign ,nonatomic)                   BOOL isLong;

@end

/**
 *	@author dingjiong, 16-06-28
 *
 *	内部使用的Model类, 不需要在外部设定, 内部已经做好处理
 *	@since 1.0
 */
@interface DJActionRulerModel : NSObject
/**
 *	@author dingjiong, 16-06-28
 *
 *	时间
 *	@since 1.0
 */
@property (retain, nonatomic)                   NSDate *date;
/**
 *	@author dingjiong, 16-06-28
 *
 *	是否有数据
 *	@since 1.0
 */
@property (assign, nonatomic,getter=isMark)     BOOL mark;

@end
