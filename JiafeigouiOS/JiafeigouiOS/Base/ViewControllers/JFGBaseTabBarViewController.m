
//
//  JFGBaseTabBarViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/1/13.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseTabBarViewController.h"
#import "JfgConfig.h"

@interface JFGBaseTabBarViewController ()

@end

@implementation JFGBaseTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabSelected:) name:JFGTabBarJumpVcKey object:nil];
    // Do any additional setup after loading the view.
}

-(void)tabSelected:(NSNotification *)notification
{
    NSNumber *number = notification.object;
    if ([number isKindOfClass:[NSNumber class]]) {
        int select = [number intValue];
        if (self.viewControllers.count>select) {
            
            self.selectedIndex = select;
            
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
