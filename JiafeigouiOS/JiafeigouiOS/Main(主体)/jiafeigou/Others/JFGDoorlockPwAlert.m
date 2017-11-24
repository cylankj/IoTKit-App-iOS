//
//  JFGDoorlockPwAlert.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/11/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGDoorlockPwAlert.h"
#import "JfgLanguage.h"

@interface JFGDoorlockPwAlert()<UITextFieldDelegate>

@property (nonatomic,weak)UIAlertAction *doorlockPwDoneAction;
@property (nonatomic,weak)UITextField *alertTextField;

@end

@implementation JFGDoorlockPwAlert

-(void)showAlertWithVC:(UIViewController *)presenVC
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[JfgLanguage getLanTextStrByKey:@"DOOR_PASSWORD"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:[JfgLanguage getLanTextStrByKey:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(jfgDoorlockPwAlertDone:)]) {
            NSString *pw = @"";
            if (weakSelf.alertTextField) {
                pw = weakSelf.alertTextField.text;
            }
            [weakSelf.delegate jfgDoorlockPwAlertDone:pw];
        }
        
        
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        textField.tag = 11112;
        textField.placeholder = [JfgLanguage getLanTextStrByKey:@"ENTER_PWD_1"];
        textField.secureTextEntry = YES;
        self.alertTextField = textField;
    }];
    
    action2.enabled = NO;
    self.doorlockPwDoneAction = action2;
    
    [alert addAction:action1];
    [alert addAction:action2];
    [presenVC presentViewController:alert animated:YES completion:nil];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *textStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.tag == 11112) {
        if (textStr.length>=6) {
            if (self.doorlockPwDoneAction) {
                self.doorlockPwDoneAction.enabled = YES;
            }
        }else{
            if (self.doorlockPwDoneAction) {
                self.doorlockPwDoneAction.enabled = NO;
            }
        }
        if (textStr.length>16) {
            return NO;
        }
    }
    return YES;
}

-(void)dealloc
{
    NSLog(@"JFGDoorlockPwAlert dealloc");
}

@end
