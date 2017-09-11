//
//  MsgFor720ViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/1.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "MsgFor720ViewController.h"
#import "MessageViewController.h"
#import "JfgLanguage.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"

@interface MsgFor720ViewController ()<MessageVCDelegate>

@property (nonatomic,strong)MessageViewController * messageVC;

@end

@implementation MsgFor720ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addChildViewController:self.messageVC];
    [self.view addSubview:self.messageVC.view];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Messages"];
    
    [self resetEditBtn];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGClearUnReadCount" object:self.cid];
}

-(void)resetEditBtn
{
    [self.messageVC.editButton removeFromSuperview];
    self.messageVC.editButton.y = self.titleLabel.y;
    self.messageVC.editButton.right = self.view.width - 15;
    [self.messageVC.editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.messageVC.editButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
    [self.topBarBgView addSubview:self.messageVC.editButton];
}

#pragma mark- messageDelegate
-(void)lookHistoryForTimestamp:(uint64_t)timestamp
{
    
}

-(MessageViewController *)messageVC{
    if (!_messageVC) {
        _messageVC = [[MessageViewController alloc]init];
        _messageVC.cid = self.cid;
        _messageVC.devModel = self.devModel;
        _messageVC.delegate = self;
        if (self.devModel.netType == JFGNetTypeOffline) {
            _messageVC.isDeviceOffline = YES;
        }else{
            _messageVC.isDeviceOffline = NO;
        }
        CGRect re = _messageVC.view.frame;
        [_messageVC.view setFrame:CGRectMake(0, 64, re.size.width, re.size.height-64)];
        
    }
    return _messageVC;
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
