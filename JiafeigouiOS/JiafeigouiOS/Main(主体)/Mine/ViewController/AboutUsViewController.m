//
//  AboutUsViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AboutUsViewController.h"
#import "JfgGlobal.h"
#import "JFGWebViewController.h"
#import "OemManager.h"
#import "JfgLanguage.h"


@interface AboutUsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UIImageView * iconImageView;
@property(nonatomic, strong)UILabel * versionLabel;
@property(nonatomic, strong)UITableView * _tableView;
@property(nonatomic, strong)UIButton * protocolButton;
@property(nonatomic, strong)UILabel * copyrightLabel;
@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"ABOUT"];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self initView];
}
-(void)initView{
    [self.view addSubview:self.iconImageView];
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@129);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    [self.view addSubview:self.versionLabel];
    [_versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(15);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@20);
    }];
    [self.view addSubview:self._tableView];
    [__tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.versionLabel.mas_bottom).offset(68);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@100);
    }];
    [self.view addSubview:self.copyrightLabel];
    [_copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-20);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@13);
    }];
    [self.view addSubview:self.protocolButton];
    [_protocolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.copyrightLabel.mas_top).offset(-10);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.greaterThanOrEqualTo(@78);
        make.height.equalTo(@13);
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL showWeb = [[[OemManager getOemConfig:oemAboutKey] objectForKey:oemShowWebKey] boolValue];
    BOOL showTEL = [[[OemManager getOemConfig:oemAboutKey] objectForKey:oemShowTELKey] boolValue];
    int rowNum = 0;
    
    if (showTEL)
    {
        rowNum ++;
    }
    if (showWeb)
    {
        rowNum ++;
    }
    if (rowNum == 0) {
        tableView.hidden = YES;
    }else{
        tableView.hidden = NO;
    }
    return rowNum;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * indentifier = @"auCell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifier];
    if (!cell) {
        cell  = [tableView dequeueReusableCellWithIdentifier:indentifier forIndexPath:indexPath];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CellSelectedColor;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    if (indexPath.row == 0) {
        cell.textLabel.text = [JfgLanguage getLanTextStrByKey:@"WEB"];
        cell.detailTextLabel.text = [JfgLanguage getLanTextStrByKey:@"web"];
        //顶部的线
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
        topLineView.backgroundColor = TableSeparatorColor;
        [cell.contentView addSubview:topLineView];
    }else {
        cell.textLabel.text = [JfgLanguage getLanTextStrByKey:@"ABOUT_PHONE"];
        NSString * number =[JfgLanguage getLanTextStrByKey:@"service_phonenum"];
        cell.detailTextLabel.text = number;
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, self.view.bounds.size.width, 0.5)];
        bottomLineView.backgroundColor = TableSeparatorColor;
        [cell.contentView addSubview:bottomLineView];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
        case 0:{
            JFGWebViewController *webViewC = [JFGWebViewController new];
            webViewC.type = webViewTypeJFG;
            [self.navigationController pushViewController:webViewC animated:YES];
        }
            break;
        case 1:{
            NSString * number =[JfgLanguage getLanTextStrByKey:@"service_phonenum"];
            
            
            NSString *num = [[NSString alloc] initWithFormat:@"telprompt://%@",number];
            NSURL * url = [NSURL URLWithString:num];
            
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                
                
                if (IOS_SYSTEM_VERSION_EQUAL_OR_ABOVE(10.0)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
                
            }

            
            
//            UIAlertController * alertC = [UIAlertController alertControllerWithTitle:number message:nil preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                [self dismissViewControllerAnimated:YES completion:nil];
//            }];
//            UIAlertAction * actionCall = [UIAlertAction actionWithTitle:[JfgLanguage getLanTextStrByKey:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////                JFGWebViewController *webViewC = [JFGWebViewController new];
////                webViewC.type = webViewTypePhone;
////                webViewC.urlString = number;
////                [self.navigationController pushViewController:webViewC animated:YES];
//                
//            }];
//            [alertC addAction:actionCancel];
//            [alertC addAction:actionCall];
//            [self.navigationController presentViewController:alertC animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

-(void)leftButtonAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)protocolButtonAction
{
    JFGWebViewController *webViewC = [JFGWebViewController new];
    webViewC.type = webViewTypeUserProtocol;
    [self.navigationController pushViewController:webViewC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"abount_jfg140"]];
        
    }
    return _iconImageView;
}

-(UILabel *)versionLabel
{
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc]init];
        _versionLabel.font = [UIFont systemFontOfSize:18];
        _versionLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _versionLabel.text = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        _versionLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _versionLabel;
}

-(UITableView *)_tableView
{
    if (!__tableView) {
        __tableView = [[UITableView alloc]init];
        __tableView.delegate = self;
        __tableView.dataSource = self;
        __tableView.showsVerticalScrollIndicator = NO;
        __tableView.showsHorizontalScrollIndicator = NO;
        __tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        __tableView.separatorColor = TableSeparatorColor;
        __tableView.backgroundColor = [UIColor clearColor];
        __tableView.scrollEnabled = NO;
    }
    return __tableView;
}

-(UIButton *)protocolButton
{
    if (!_protocolButton) {
        _protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_protocolButton setTitleColor:[UIColor colorWithHexString:@"4b9fd5"] forState:UIControlStateNormal];
        [_protocolButton setTitle:[JfgLanguage getLanTextStrByKey:@"TERM_OF_USE"] forState:UIControlStateNormal];
        [_protocolButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_protocolButton addTarget:self action:@selector(protocolButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _protocolButton.hidden = ![[OemManager getOemConfig:oemShowProtocolKey] boolValue];
    }
    return _protocolButton;
}
-(UILabel *)copyrightLabel{
    if (!_copyrightLabel) {
        _copyrightLabel = [[UILabel alloc]init];
        _copyrightLabel.textColor = [UIColor colorWithHexString:@"#adadad"];
        _copyrightLabel.font = [UIFont systemFontOfSize:12];
        _copyrightLabel.text = @"Copyright ©2005-2017 Cylan.All Rights Reserved";
        _copyrightLabel.textAlignment = NSTextAlignmentCenter;
        _copyrightLabel.hidden = ![[OemManager getOemConfig:oemShowCopyRightKey] boolValue];
    }
    return _copyrightLabel;
}
@end
