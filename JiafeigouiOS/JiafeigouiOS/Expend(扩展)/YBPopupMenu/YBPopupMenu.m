//
//  YBPopupMenu.m
//  YBPopupMenu
//
//  Created by LYB on 16/11/8.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import "YBPopupMenu.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgGlobal.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kMainWindow  [UIApplication sharedApplication].keyWindow



#pragma mark - /////////////
#pragma mark - private cell

#define rowHeight 53

@interface YBPopupMenuCell : UITableViewCell
@property (nonatomic, assign) BOOL isShowSeparator;
@property (nonatomic, strong) UIColor * separatorColor;

@property (nonatomic, strong) UIImageView *iconImgeView;
@property (nonatomic, strong) UIButton *iconTitleButton;
@property (nonatomic, strong) UILabel *iconTitleLabel;

@property (nonatomic, assign) BOOL canClicked;
@end

@implementation YBPopupMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _isShowSeparator = YES;
        _separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        [self addSubview:self.iconImgeView];
        [self.iconImgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(25.0f);
            make.centerY.equalTo(self);
        }];
        [self addSubview:self.iconTitleLabel];
        [self.iconTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImgeView.mas_right).with.offset(15.0f);
            make.centerY.equalTo(self);
        }];
        
        [self setNeedsDisplay];
    }
    return self;
}

- (void)setIsShowSeparator:(BOOL)isShowSeparator
{
    _isShowSeparator = isShowSeparator;
    [self setNeedsDisplay];
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    [self setNeedsDisplay];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    //self.iconTitleLabel.textColor = [UIColor colorWithHexString:highlighted?@"#4b9fd5":@"#666666"];
}

- (void)setCanClicked:(BOOL)canClicked
{
    _canClicked = canClicked;
    
    self.userInteractionEnabled = _canClicked;
    self.iconImgeView.alpha = _canClicked?1.0:0.6f;
    self.iconTitleLabel.alpha = _canClicked?1.0:0.6f;
}

- (void)drawRect:(CGRect)rect
{
    if (!_isShowSeparator) return;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5)];
    [_separatorColor setFill];
    [bezierPath fillWithBlendMode:kCGBlendModeNormal alpha:1];
    [bezierPath closePath];
}

- (UIImageView *)iconImgeView
{
    if (_iconImgeView == nil)
    {
        _iconImgeView = [[UIImageView alloc] init];
    }
    return _iconImgeView;
}

- (UILabel *)iconTitleLabel
{
    if (_iconTitleLabel == nil)
    {
        _iconTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImgeView.right + 15, (rowHeight-16.0)*0.5, kScreenWidth, 16.0f)];
        _iconTitleLabel.textAlignment = NSTextAlignmentLeft;
        _iconTitleLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        _iconTitleLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    
    return _iconTitleLabel;
}

@end


#pragma mark - ///////////
#pragma mark - YBPopupMenu

@interface YBPopupMenu ()
<
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation YBPopupMenu
{
    
    UIView * _mainView;
    UITableView * _contentView;
    UIView * _bgView;
    
    CGPoint _anchorPoint;
    
    // 箭头
    CGFloat kArrowHeight;
    CGFloat kArrowWidth;
    CGFloat kArrowPosition;
    
    CGFloat kButtonHeight;
    
    NSArray * _titles;
    NSArray * _icons;
    
    UIColor * _contentColor;
    UIColor * _separatorColor;
}

@synthesize cornerRadius = kCornerRadius;

- (instancetype)initWithTitles:(NSArray *)titles
                         icons:(NSArray *)icons
                     menuWidth:(CGFloat)itemWidth
                      delegate:(id<YBPopupMenuDelegate>)delegate
{
    if (self = [super init]) {
        
        kArrowHeight = 10;
        kArrowWidth = 15;
        
        kCornerRadius = 5.0;
        
        kButtonHeight = 53;
        
        _titles = titles;
        _icons  = icons;
        _dismissOnSelected = YES;
        _fontSize = 16.0;
        _textColor = [UIColor blackColor];
        _offset = 0.0;
        _type = YBPopupMenuTypeDefault;
        _contentColor = [UIColor whiteColor];
        _separatorColor = [UIColor lightGrayColor];
        
        if (delegate) self.delegate = delegate;
        
        self.width = itemWidth;
//        (titles.count > 5 ? 5 * kButtonHeight : titles.count * kButtonHeight) + 2 * kArrowHeight
        self.height = (titles.count > 5 ? 5 * kButtonHeight : titles.count * kButtonHeight);
        
        kArrowPosition = 0.5 * self.width - 0.5 * kArrowWidth;
        
        self.alpha = 0;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2.0;
        
        _mainView = [[UIView alloc] initWithFrame:self.bounds];
        _mainView.backgroundColor = _contentColor;
        _mainView.layer.cornerRadius = kCornerRadius;
        _mainView.layer.masksToBounds = YES;
        
        _contentView = [[UITableView alloc] initWithFrame: _mainView.bounds style:UITableViewStylePlain];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.delegate = self;
        _contentView.dataSource= self;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.scrollEnabled = NO;
        _contentView.bounces = titles.count > 5 ? YES : NO;
        _contentView.tableFooterView = [UIView new];
        _contentView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [_contentView setSeparatorInset:UIEdgeInsetsMake(50, 50, 0, 0)];
        _contentView.height -= 2 * kArrowHeight;
        _contentView.y = _mainView.y;
        
        [_mainView addSubview: _contentView];
        [self addSubview: _mainView];
        
        _bgView = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _bgView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(dismiss)];
        [_bgView addGestureRecognizer: tap];
    }
    return self;
}

- (void)dismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuBeganDismiss)]) {
        [self.delegate ybPopupMenuBeganDismiss];
    }
    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
        _bgView.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidDismiss)]) {
            [self.delegate ybPopupMenuDidDismiss];
        }
        self.delegate = nil;
        [self removeFromSuperview];
        [_bgView removeFromSuperview];
    }];
}

- (void)showAtPoint:(CGPoint)point
{
    _mainView.layer.mask = [self getMaskLayerWithPoint:point];
    [self show];
}

- (void)showRelyOnView:(UIView *)view
{
    CGRect absoluteRect = [view convertRect:view.bounds toView:kMainWindow];
    CGPoint relyPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y + absoluteRect.size.height);
    _mainView.layer.mask = [self getMaskLayerWithPoint:relyPoint];
    if (self.top < _anchorPoint.y) {
        self.top -= absoluteRect.size.height;
    }
    [self show];
}

+ (instancetype)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<YBPopupMenuDelegate>)delegate
{
    YBPopupMenu *popupMenu = [[YBPopupMenu alloc] initWithTitles:titles icons:icons menuWidth:itemWidth delegate:delegate];
    [popupMenu showAtPoint:point];
    return popupMenu;
}

+ (instancetype)showRelyOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<YBPopupMenuDelegate>)delegate
{
    YBPopupMenu *popupMenu = [[YBPopupMenu alloc] initWithTitles:titles icons:icons menuWidth:itemWidth delegate:delegate];
    [popupMenu showRelyOnView:view];
    return popupMenu;
}

#pragma mark tableViewDelegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ybPopupMenu";
    YBPopupMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[YBPopupMenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.iconTitleLabel.textColor = _textColor;
    cell.iconTitleLabel.font = [UIFont systemFontOfSize:_fontSize];
    cell.iconTitleLabel.text = _titles[indexPath.row];
    cell.separatorColor = _separatorColor;
    
    switch (indexPath.row)
    {
        case 0:
        {
            cell.canClicked = self.firstCellCanClicked;
        }
            break;
        case 1:
        {
            cell.canClicked = self.secondCellCanClicked;
        }
            break;
        default:
        {
            cell.canClicked = YES;
        }
            break;
    }
    
    if (_icons.count >= indexPath.row + 1)
    {
        if ([_icons[indexPath.row] isKindOfClass:[NSString class]])
        {
            cell.iconImgeView.image = [UIImage imageNamed:_icons[indexPath.row]];
        }else if ([_icons[indexPath.row] isKindOfClass:[UIImage class]])
        {
            cell.iconImgeView.image = _icons[indexPath.row];
        }
        else
        {
            cell.iconImgeView.image = nil;
        }
    }else {
        cell.iconImgeView.image = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_dismissOnSelected) [self dismiss];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidSelectedAtIndex:ybPopupMenu:)]) {
        
        [self.delegate ybPopupMenuDidSelectedAtIndex:indexPath.row ybPopupMenu:self];
    }
}


#pragma mark - scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    YBPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    YBPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = NO;
}

- (YBPopupMenuCell *)getLastVisibleCell
{
    NSArray <NSIndexPath *>*indexPaths = [_contentView indexPathsForVisibleRows];
    indexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        return (NSComparisonResult)(obj1.row < obj2.row);
    }];
    NSIndexPath *indexPath = indexPaths.firstObject;
    return [_contentView cellForRowAtIndexPath:indexPath];
}

#pragma mark private functions
- (void)setType:(YBPopupMenuType)type
{
    _type = type;
    switch (type) {
        case YBPopupMenuTypeDark:
        {
            _textColor = [UIColor lightGrayColor];
//            _contentColor = [UIColor colorWithRed:0.25 green:0.27 blue:0.29 alpha:1];
            _contentColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.6];
            _separatorColor = [UIColor lightGrayColor];
        }
            break;
            
        default:
        {
            _textColor = [UIColor blackColor];
            _contentColor = [UIColor whiteColor];
            _separatorColor = [UIColor lightGrayColor];
        }
            break;
    }
    _mainView.backgroundColor = _contentColor;
    [_contentView reloadData];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [_contentView reloadData];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [_contentView reloadData];
}

- (void)setFirstCellCanClicked:(BOOL)firstCellCanClicked
{
    _firstCellCanClicked = firstCellCanClicked;
    [_contentView reloadData];
}

- (void)setSecondCellCanClicked:(BOOL)secondCellCanClicked
{
    _secondCellCanClicked = secondCellCanClicked;
    [_contentView reloadData];
}

- (void)setRows:(NSArray *)rows
{
    _titles = rows;
    
    [_contentView reloadData];
}

- (void)setDismissOnTouchOutside:(BOOL)dismissOnTouchOutside
{
    _dismissOnSelected = dismissOnTouchOutside;
    if (!dismissOnTouchOutside) {
        for (UIGestureRecognizer *gr in _bgView.gestureRecognizers) {
            [_bgView removeGestureRecognizer:gr];
        }
    }
}

- (void)setIsShowShadow:(BOOL)isShowShadow
{
    _isShowShadow = isShowShadow;
    if (!isShowShadow) {
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 0.0;
    }
}

- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    if (offset < 0) {
        offset = 0.0;
    }
    self.top += self.top >= _anchorPoint.y ? offset : -offset;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    kCornerRadius = cornerRadius;
    _mainView.layer.mask = [self drawMaskLayer];
    if (self.top < _anchorPoint.y) {
        _mainView.layer.mask.affineTransform = CGAffineTransformMakeRotation(M_PI);
    }
}

- (void)show {
    
    [kMainWindow addSubview: _bgView];
    [kMainWindow addSubview: self];
    YBPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = NO;
    self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
        _bgView.alpha = 1;
    }];
}

- (void)setAnimationAnchorPoint:(CGPoint)point
{
    CGRect originRect = self.frame;
    self.layer.anchorPoint = point;
    self.frame = originRect;
}

- (void)determineAnchorPoint
{
    CGPoint aPoint = CGPointMake(0.5, 0.5);
    if (CGRectGetMaxY(self.frame) > kScreenHeight) {
        aPoint = CGPointMake(fabs(kArrowPosition) / self.width, 1);
    }else {
        aPoint = CGPointMake(fabs(kArrowPosition) / self.width, 0);
    }
    [self setAnimationAnchorPoint:aPoint];
}

- (CAShapeLayer *)getMaskLayerWithPoint:(CGPoint)point
{
    [self setArrowPointingWhere:point];
    CAShapeLayer *layer = [self drawMaskLayer];
    [self determineAnchorPoint];
    if (CGRectGetMaxY(self.frame) > kScreenHeight) {
        
        kArrowPosition = self.width - kArrowPosition - kArrowWidth;
        layer = [self drawMaskLayer];
        layer.affineTransform = CGAffineTransformMakeRotation(M_PI);
        self.top = _anchorPoint.y - self.height;
    }
    self.top += self.top >= _anchorPoint.y ? _offset : -_offset;
    return layer;
}

- (void)setArrowPointingWhere: (CGPoint)anchorPoint
{
    _anchorPoint = anchorPoint;
    
    self.left = anchorPoint.x - kArrowPosition - 0.5*kArrowWidth;
    self.top = anchorPoint.y;
    
    CGFloat maxX = CGRectGetMaxX(self.frame);
    CGFloat minX = CGRectGetMinX(self.frame);
    
    if (maxX > kScreenWidth - 10) {
        self.left = kScreenWidth - 10 - self.width;
    }else if (minX < 10) {
        self.left = 10;
    }
    
    maxX = CGRectGetMaxX(self.frame);
    minX = CGRectGetMinX(self.frame);
    
    if ((anchorPoint.x <= maxX - kCornerRadius) && (anchorPoint.x >= minX + kCornerRadius)) {
        kArrowPosition = anchorPoint.x - minX - 0.5*kArrowWidth;
    }else if (anchorPoint.x < minX + kCornerRadius) {
        kArrowPosition = kCornerRadius;
    }else {
        kArrowPosition = self.width - kCornerRadius - kArrowWidth;
    }
}

- (CAShapeLayer *)drawMaskLayer
{
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = _mainView.bounds;
    
    CGPoint topRightArcCenter = CGPointMake(self.width-kCornerRadius, kArrowHeight+kCornerRadius);
    CGPoint topLeftArcCenter = CGPointMake(kCornerRadius, kArrowHeight+kCornerRadius);
    CGPoint bottomRightArcCenter = CGPointMake(self.width-kCornerRadius, self.height - kArrowHeight - kCornerRadius);
    CGPoint bottomLeftArcCenter = CGPointMake(kCornerRadius, self.height - kArrowHeight - kCornerRadius);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(0, kArrowHeight+kCornerRadius)];
    [path addLineToPoint: CGPointMake(0, bottomLeftArcCenter.y)];
    [path addArcWithCenter: bottomLeftArcCenter radius: kCornerRadius startAngle: -M_PI endAngle: -M_PI-M_PI_2 clockwise: NO];
    [path addLineToPoint: CGPointMake(self.width-kCornerRadius, self.height - kArrowHeight)];
    [path addArcWithCenter: bottomRightArcCenter radius: kCornerRadius startAngle: -M_PI-M_PI_2 endAngle: -M_PI*2 clockwise: NO];
    [path addLineToPoint: CGPointMake(self.width, kArrowHeight+kCornerRadius)];
    [path addArcWithCenter: topRightArcCenter radius: kCornerRadius startAngle: 0 endAngle: -M_PI_2 clockwise: NO];
    [path addLineToPoint: CGPointMake(kArrowPosition+kArrowWidth, kArrowHeight)];
    [path addLineToPoint: CGPointMake(kArrowPosition+0.5*kArrowWidth, 0)];
    [path addLineToPoint: CGPointMake(kArrowPosition, kArrowHeight)];
    [path addLineToPoint: CGPointMake(kCornerRadius, kArrowHeight)];
    [path addArcWithCenter: topLeftArcCenter radius: kCornerRadius startAngle: -M_PI_2 endAngle: -M_PI clockwise: NO];
    [path closePath];
    
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}

@end
