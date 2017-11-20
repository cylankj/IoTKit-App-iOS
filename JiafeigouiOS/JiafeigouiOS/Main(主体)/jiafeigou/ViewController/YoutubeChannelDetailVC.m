//
//  YoutubeChannelDetailVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/7.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "YoutubeChannelDetailVC.h"
#import "YoutubeCreatChannelVC.h"
#import "YoutubeLiveStreamsModel.h"
#import <Masonry.h>

@interface YoutubeChannelDetailVC ()

@property (nonatomic,strong)UIImageView *headImageView;
@property (nonatomic,strong)UILabel *channelTitleLabel;
@property (nonatomic,strong)UILabel *channelDetailLabel;
@property (nonatomic,strong)TimeCell *startTimeCell;
@property (nonatomic,strong)TimeCell *endTimeCell;

@end

@implementation YoutubeChannelDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_CURRENT_TEXT"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F0F0F0"];
    [self initView];
    [self initNavagationView];
    // Do any additional setup after loading the view.
}

-(void)initView
{
    [self.view addSubview:self.headImageView];
    [self.view addSubview:self.channelTitleLabel];
    [self.view addSubview:self.channelDetailLabel];
    [self.view addSubview:self.endTimeCell];
    [self.view addSubview:self.startTimeCell];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(15, self.startTimeCell.bottom-0.25, self.view.width-15, 0.5)];
    lineView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:lineView];
}

-(void)initNavagationView
{
    [self.topBarBgView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@2);
        make.centerY.mas_equalTo(self.topBarBgView.mas_bottom).offset(-22);
        make.height.greaterThanOrEqualTo(@50);
        make.width.greaterThanOrEqualTo(@50);
    }];
}

-(UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pic_youtube"]];
        _headImageView.top = 84;
        _headImageView.x = self.view.width*0.5;
    }
    return _headImageView;
}

-(UILabel *)channelTitleLabel
{
    if (!_channelTitleLabel) {
        _channelTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 204, self.view.width-30, 18)];
        _channelTitleLabel.font = [UIFont systemFontOfSize:17];
        _channelTitleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _channelTitleLabel.text = self.dataModel.title;
    }
    return _channelTitleLabel;
}

-(UILabel *)channelDetailLabel
{
    if (!_channelDetailLabel) {
        _channelDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 234, self.view.width-30, 44)];
        _channelDetailLabel.font = [UIFont systemFontOfSize:14];
        _channelDetailLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        _channelDetailLabel.numberOfLines = 2;
        _channelDetailLabel.text = self.dataModel.descrips;
    }
    return _channelDetailLabel;
}

-(TimeCell *)startTimeCell
{
    if (!_startTimeCell) {
        _startTimeCell =[[TimeCell alloc]initWithFrame:CGRectMake(0, 334, self.view.width, 44)];
        if (self.dataModel.scheduledStartTime) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *str = [dateFormatter stringFromDate:self.dataModel.scheduledStartTime];
            _startTimeCell.detailLabel.text = str;
        }else{
            _startTimeCell.detailLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_SET"];
        }
    }
    return _startTimeCell;
}

-(TimeCell *)endTimeCell
{
    if (!_endTimeCell) {
        _endTimeCell =[[TimeCell alloc]initWithFrame:CGRectMake(0, 378, self.view.width, 44)];
        _endTimeCell.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"TO"];
        if (self.dataModel.scheduledEndTime) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *str = [dateFormatter stringFromDate:self.dataModel.scheduledEndTime];
            _endTimeCell.detailLabel.text = str;
        }else{
            _endTimeCell.detailLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_SET"];
        }
    }
    return _endTimeCell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
