//
//  FullScreenHistoryDatePicker.m
//  HeaderRotation
//
//  Created by 杨利 on 16/6/29.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "FullScreenHistoryDatePicker.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+FLExtension.h"

@interface FullScreenHistoryDatePicker()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UIView *tableViewBgView;
@property (nonatomic,strong)UITableView *tableView;

@end

@implementation FullScreenHistoryDatePicker

-(instancetype)initWithFrame:(CGRect)frame
{
    CGRect newFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    self = [super initWithFrame:newFrame];
    
    self.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    self.backgroundColor = [UIColor clearColor];
    
    [self initView];
    
    return self;
}

#pragma mark- tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @";";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idCell];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idCell];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        UILabel *titLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 210, 40)];
        titLabel.backgroundColor = [UIColor clearColor];
        titLabel.textColor = [UIColor whiteColor];
        titLabel.font = [UIFont systemFontOfSize:18];
        titLabel.textAlignment = NSTextAlignmentCenter;
        titLabel.tag = 18021;
        [cell.contentView addSubview:titLabel];
        
        UIImageView *imageVie = [[UIImageView alloc]initWithFrame:CGRectMake(0, 49, 220, 1)];
        imageVie.image = [UIImage imageNamed:@"full_history_line"];
        [cell.contentView addSubview:imageVie];
        
    }
    
    NSString *title = [self.dataArray objectAtIndex:indexPath.row];
    UILabel *tL = [cell.contentView viewWithTag:18021];
    tL.text = title;
    
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *tL = [cell.contentView viewWithTag:18021];
    tL.textColor = [UIColor colorWithHexString:@"#4b9fd5"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedItem:index:)]) {
        [self.delegate selectedItem:tL.text index:indexPath.row];
    }
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.5];
}

-(void)initView
{
    [self addSubview:self.tableViewBgView];
    [self.tableViewBgView addSubview:self.tableView];
}

+(instancetype)fullScreenHistoryDatePicker
{
    FullScreenHistoryDatePicker *full = [[FullScreenHistoryDatePicker alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    return full;
}

-(void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.tableViewBgView.left = [UIScreen mainScreen].bounds.size.height;
    [keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableViewBgView.left = [UIScreen mainScreen].bounds.size.height-290;
    }];
}

-(void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
         self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

-(void)setDataArray:(NSArray *)dataArray
{
    if (dataArray && dataArray != _dataArray) {
        
        _dataArray = [[NSArray alloc]initWithArray:dataArray];
        [self.tableView reloadData];
        
    }
}

-(UIView *)tableViewBgView
{
    if (!_tableViewBgView) {
        _tableViewBgView = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.height-290, 0, 290, [UIScreen mainScreen].bounds.size.width)];
        _tableViewBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    return _tableViewBgView;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake((self.tableViewBgView.width-220)*0.5, 0, 220, [UIScreen mainScreen].bounds.size.width) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
