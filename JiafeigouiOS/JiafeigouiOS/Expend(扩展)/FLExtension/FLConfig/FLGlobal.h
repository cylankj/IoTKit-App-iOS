//
//  FLGlobal.h
//  FLJobClub
//
//  Created by 紫贝壳 on 15/8/12.
//  Copyright (c) 2015年 FL. All rights reserved.
//
#pragma mark Color
//Cell选中颜色,注意导入头文件#import "UIColor+HexColor.h"
#define CellSelectedColor [UIColor colorWithHexString:@"#dfdfdf"]
//separator颜色
#define TableSeparatorColor [UIColor colorWithHexString:@"#e1e1e1"]
//主要字体颜色
#define MainTextColor [UIColor colorWithHexString:@"#333333"]
#pragma mark Screen
/// 屏幕高度、宽度
#define Kwidth [[UIScreen mainScreen] bounds].size.width
#define kheight [[UIScreen mainScreen] bounds].size.height

#define designHscale  kheight/667.0f
#define designWscale  Kwidth/375.0f

#pragma mark - System Version
/// 当前系统版本大于等于某版本
#define IOS_SYSTEM_VERSION_EQUAL_OR_ABOVE(v) (([[[UIDevice currentDevice] systemVersion] floatValue] >= (v))? (YES):(NO))
/// 当前系统版本小于等于某版本
#define IOS_SYSTEM_VERSION_EQUAL_OR_BELOW(v) (([[[UIDevice currentDevice] systemVersion] floatValue] <= (v))? (YES):(NO))


#pragma mark - view size, frame
/** 根据字符串、最大尺寸、字体计算字符串最合适尺寸 */
static inline CGSize CGSizeOfString(NSString * text, CGSize maxSize, UIFont * font) {
    CGSize fitSize;
#ifdef __IPHONE_7_0
    
    fitSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
#else
    fitSize = [text sizeWithFont:font constrainedToSize:maxSize];
#endif
    return fitSize;
}

// 控制台输出
#ifdef DEBUG
#define JFGLog(FORMAT, ...) do {fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);} while(0)
#else
#define JFGLog(...)
#endif

//读取本地图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

//定义UIImage对象
#define ImageNamed(_pointer) [UIImage imageNamed:[UIUtil imageName:_pointer]]

//定义颜色
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]
