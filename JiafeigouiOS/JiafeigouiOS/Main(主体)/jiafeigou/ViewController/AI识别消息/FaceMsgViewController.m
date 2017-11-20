//
//  FaceMsgViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "FaceMsgViewController.h"
#import "YoutubeCreatChannelVC.h"
#import "SetDeviceNameVC.h"
#import "FaceManagerViewController.h"
#import "UIImageView+JFGImageView.h"
#import "MsgForAIRequest.h"

@interface FaceMsgViewController ()<MsgForAIRequestDelegate>
{
    MsgForAIRequest *msgReq;
}
@property (nonatomic,strong)UIImageView *headerImageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)TimeCell *nameCell;
@property (nonatomic,strong)TimeCell *faceManagerCell;
@property (nonatomic,strong)UIView *lineView;
@end

@implementation FaceMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_INFO"];
    msgReq = [[MsgForAIRequest alloc]init];
    msgReq.delegate = self;
    
    [self.view addSubview:self.headerImageView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.nameCell];
    [self.view addSubview:self.faceManagerCell];
    [self.view addSubview:self.lineView];
    self.nameLabel.text = self.person_name;
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [msgReq addJfgDelegate];
    [msgReq reqPersonNameForID:self.person_id cid:self.cid];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [msgReq removeJfgDelegate];
}

-(void)msgForAIPersonName:(NSString *)personName person_id:(NSString *)person_id cid:(NSString *)cid
{
    if ([cid isEqualToString:self.cid]) {
        
        self.nameLabel.text = personName;
        self.nameCell.detailLabel.text = personName;
        self.msgModel.name = personName;
        
    }
}

-(void)nameCellDidSelected
{
    SetDeviceNameVC *nameVC = [SetDeviceNameVC new];
    nameVC.deviceNameVCType = DeviceNameVCTypeSetFaceName;
    nameVC.deviceName = self.nameLabel.text;
    nameVC.person_id = self.person_id;
    nameVC.cid = self.cid;
    [self.navigationController pushViewController:nameVC animated:YES];
}

-(void)faceManagerDidSelected
{
    FaceManagerViewController *faceManager = [FaceManagerViewController new];
    faceManager.msgModel = self.msgModel;
    faceManager.cid = self.cid;
    [self.navigationController pushViewController:faceManager animated:YES];
}

-(UIImageView *)headerImageView
{
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 112, 90, 90)];
        _headerImageView.x = self.view.width*0.5;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.cornerRadius = 45;
        [_headerImageView jfg_setImageWithURL:[NSURL URLWithString:self.headImageUrl] placeholderImage:[UIImage imageNamed:@"news_head128"]];
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headerImageView;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 212, self.view.width-20, 20)];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.text = @"";
    }
    return _nameLabel;
}


-(TimeCell *)nameCell
{
    if (!_nameCell) {
        _nameCell = [[TimeCell alloc]initWithFrame:CGRectMake(0, 271, self.view.width, 44)];
        _nameCell.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"NAME"];
        _nameCell.detailLabel.text = self.person_name;
        [_nameCell addTarget:self action:@selector(nameCellDidSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nameCell;
}

-(TimeCell *)faceManagerCell
{
    if (!_faceManagerCell) {
        _faceManagerCell = [[TimeCell alloc]initWithFrame:CGRectMake(0, 315, self.view.width, 44)];
        _faceManagerCell.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_MABAGE"];
        _faceManagerCell.detailLabel.text = @"";
        [_faceManagerCell addTarget:self action:@selector(faceManagerDidSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceManagerCell;
}

-(UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(15, 314.5, self.view.width-15, 1)];
        _lineView.backgroundColor = self.view.backgroundColor;
    }
    return _lineView;
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
