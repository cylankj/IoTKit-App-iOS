//
//  FLCycleAdView.h
//  CycleScrollView
//
//  Created by 紫贝壳 on 15/8/17.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLCycAdViewDelegate;

typedef void(^TapItemBlock)(NSInteger index);

@interface FLCycleAdView : UIView

/**显示滚动图片数组*/
@property (nonatomic,strong)NSArray *imagesList;

/**标题数组*/
@property (nonatomic,strong)NSArray *titlesList;

/**自动滚动时间间隔*/
@property (nonatomic,assign)NSInteger autoScrollerTimeInterval;

/**标记*/
@property (nonatomic,copy)NSString *userInfo;

/**代理*/
@property (nonatomic,assign)id <FLCycAdViewDelegate> delegate;


/**点击广告栏block回调*/
@property (nonatomic,copy)TapItemBlock tapItemBlock;

/**
 通过图片数组创建一个循环滚动视图
 @pram timeInterval 定时器间隔时间
 */
+(instancetype)flCycleAdViewWithFrame:(CGRect)frame
                         imageList:(NSArray *)imageList
                         timeInterval:(NSTimeInterval)timeInterval;

/**
 通过图片数组与标题数组创建一个循环滚动视图
 */
+(instancetype)flCycleAdViewWithFrame:(CGRect)frame
                         imageList:(NSArray *)imageList
                            titleList:(NSArray *)titleList
                         timeInterval:(NSTimeInterval)timeInterval;
/**
 刷新显示数据
 注意：使用上面两个方法创建AdView后不需要调用此方法，仅当创建完成后，需要更改显示数据(titleList,autoScrollerTimeInterval,imagesList)，更改后调用此方法，数据生效
 */
-(void)reloadData;


@end


#pragma mark Delegate
@protocol FLCycAdViewDelegate <NSObject>

@optional
-(void)flCycAdView:(FLCycleAdView *)adView didSelectItemAtIndex:(NSInteger)index;

@end




