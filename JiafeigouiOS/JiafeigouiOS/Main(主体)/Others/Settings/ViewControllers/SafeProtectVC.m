//
//  SafeProtectVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SafeProtectVC.h"
#import "JfgGlobal.h"
#import "HistoryDatePicker.h"
#import "JfgTableViewCellKey.h"
#import "JfgUserDefaultKey.h"
#import "PropertyManager.h"
#import "SafeProtectModel.h"
#import "AIRecognitionVC.h"
#import "subSafeProtectVC.h"
#import "FaceRecognitionSettingVC.h"

@interface SafeProtectVC ()<subSafeProtectDelegate, AIRecognitionDelegate>

@property (strong, nonatomic) SafeProtectTableView *protectTableView;

@end

@implementation SafeProtectVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigation];
    [self initViewLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.protectTableView reloadData]; //这里刷新 是 为了 清除 小红点
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark view
- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SECURE"];
}

- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    
    [self.view addSubview:self.protectTableView];
}

- (void)initViewLayout
{
    [self.protectTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
    }];
}

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(moveDectionChanged:repeatTime:begin:end:)])
    {
        [_delegate moveDectionChanged:self.protectTableView.safeProtectVM.isWarnEnable repeatTime:self.protectTableView.safeProtectVM.repeat begin:self.protectTableView.safeProtectVM.beginTime end:self.protectTableView.safeProtectVM.endTime];
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(warnRelativeAutoPhoto:)])
    {
        if (self.protectTableView.autoPhotoType == MotionDetectNever)
        {
            [_delegate warnRelativeAutoPhoto:self.protectTableView.autoPhotoType];
        }
    }
}


#pragma mark getter
- (SafeProtectTableView *)protectTableView
{
    if (_protectTableView == nil)
    {
        _protectTableView = [[SafeProtectTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _protectTableView.safeTableViewDelegate = self;
        _protectTableView.pType = self.pType;
        _protectTableView.cid = self.cid;
    }
    
    return _protectTableView;
}
#pragma mark VC Delegate
// 更新 设备提示音
- (void)updateDeviceVoice:(int)voiccType duration:(int)repeatTime
{
    [self.protectTableView.safeProtectVM updatevoiceType:voiccType time:repeatTime];
}

// 更新 重复 日期
- (void)updateRepeatDate:(int)repeatDate
{
    [self.protectTableView.safeProtectVM updateRepeatDate:repeatDate];
}

// 更新AI
- (void)updateAIRecognition:(NSArray *)aiTypes
{
    [self.protectTableView.safeProtectVM updateAIRecgnition:aiTypes];
}

#pragma mark TableView Delegate
- (void)tableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo
{
    NSString *cellID = [dataInfo objectForKey:cellUniqueID];
    
    if ([cellID isEqualToString:idCellWarnSound])
    {
        [self pushSubSafeWarnSoundVC:dataInfo];
    }
    else if ([cellID isEqualToString:idCellRepeatTime])
    {
        [self pushSubSafeRepeatTimeVC:dataInfo];
    }
    else if ([cellID isEqualToString:idCellAIRecognition])
    {
        [self pushSubSafeAIRecogVC:dataInfo];
    }else if ([cellID isEqualToString:idCellFaceRecognition]){
        
        [self pushSubSafeFaceRecogVC:dataInfo];
        
    }
}


- (void)moveDectionChanged:(BOOL)isOpen repeatTime:(int)repeat begin:(int)begin end:(int)end
{

}

- (void)pushSubSafeWarnSoundVC:(NSDictionary *)dataInfo
{
    SafeProtectModel *safeModel = [dataInfo objectForKey:cellHiddenText];
    
    subSafeProtectVC *deviceVoice = [[subSafeProtectVC alloc] init];
    deviceVoice.cid = self.cid;
    deviceVoice.myDelegate = self;
    deviceVoice.protectType = SafeProtectTypeDeviceVoice;
    deviceVoice.oldVoiceType = (soundType)safeModel.soundType;
    deviceVoice.oldRepeatTime = safeModel.soundTime;
    [self.navigationController pushViewController:deviceVoice animated:YES];
}

- (void)pushSubSafeRepeatTimeVC:(NSDictionary *)dataInfo
{
    subSafeProtectVC *reaptTime = [[subSafeProtectVC alloc] init];
    reaptTime.myDelegate = self;
    reaptTime.oldRepeatDate = [[dataInfo objectForKey:cellHiddenText] intValue];
    reaptTime.cid = self.cid;
    reaptTime.protectType = SafeProtectTypeProtectTime;
    [self.navigationController pushViewController:reaptTime animated:YES];
}

- (void)pushSubSafeAIRecogVC:(NSDictionary *)dataInfo
{
    AIRecognitionVC *ai = [[AIRecognitionVC alloc] init];
    ai.delegate = self;
    ai.cid = self.cid;
    ai.pType = self.pType;
    [self.navigationController pushViewController:ai animated:YES];
}

-(void)pushSubSafeFaceRecogVC:(NSDictionary *)dataInfo
{
    FaceRecognitionSettingVC *fac = [FaceRecognitionSettingVC new];
    fac.cid = self.cid;
    fac.pType = self.pType;
    [self.navigationController pushViewController:fac animated:YES];
}

@end
