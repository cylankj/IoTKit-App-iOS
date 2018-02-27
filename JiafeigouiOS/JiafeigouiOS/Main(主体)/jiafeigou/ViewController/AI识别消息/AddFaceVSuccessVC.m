//
//  AddFaceVSuccessVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2018/1/26.
//  Copyright © 2018年 lirenguang. All rights reserved.
//

#import "AddFaceVSuccessVC.h"

@interface AddFaceVSuccessVC ()

@property (nonatomic,strong)UIButton *doneBtn;
@property (nonatomic,strong)UILabel *titleTextLabel;
@property (nonatomic,strong)UIButton *nextBtn;

@end

@implementation AddFaceVSuccessVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.backBtn.hidden = YES;
    self.topBarBgView.hidden = YES;
    [self.view addSubview:self.doneBtn];
    [self.view addSubview:self.titleTextLabel];
    [self.view addSubview:self.nextBtn];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AIFaceRegisterSuccess" object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
  self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
     self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(void)doneAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)nextAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addFaceSucessNextAction)]) {
        [self.delegate addFaceSucessNextAction];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIButton *)doneBtn
{
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(0, 0, 50, 20);
        _doneBtn.top = 41;
        _doneBtn.right = self.view.width-15;
        _doneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_doneBtn setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
        [_doneBtn setTitle:[JfgLanguage getLanTextStrByKey:@"FINISHED"] forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

-(UILabel *)titleTextLabel
{
    if (!_titleTextLabel) {
        _titleTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width-40, 30)];
        _titleTextLabel.font = [UIFont systemFontOfSize:22];
        _titleTextLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleTextLabel.x = self.view.width/2;
        _titleTextLabel.top = 215;
        _titleTextLabel.text = self.titleText;
        _titleTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleTextLabel;
}

-(UIButton *)nextBtn
{
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.size = CGSizeMake(180, 44);
        _nextBtn.x = self.view.width/2;
        _nextBtn.top = 284;
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextBtn setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
        [_nextBtn setTitle:self.actionText forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
        _nextBtn.layer.masksToBounds = YES;
        _nextBtn.layer.cornerRadius = 22;
        _nextBtn.layer.borderWidth = 0.5;
        _nextBtn.layer.borderColor = [UIColor colorWithHexString:@"#D8D8D8"].CGColor;
    }
    return _nextBtn;
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
