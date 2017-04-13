//
//  HelpViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "HelpViewController.h"
#import "JfgGlobal.h"
#import "LSChatCell.h"
#import "LSChatModel.h"
#import "LSBookManager.h"
#import "InsetsTextField.h"
#import <JFGSDK/JFGSDK.h>
#import "ProgressHUD.h"
#import "CommonMethod.h"
#import <SDImageCache.h>
#import "LSAlertView.h"
#import "LoginManager.h"
#import "CommonMethod.h"
//用这个库是为了防止cell高度变化引起的明显抖动
#import <UITableView+FDTemplateLayoutCell.h>
#import <ZipArchive/ZipArchive.h>
#import "JfgConfig.h"
#import "UIImageView+JFGImageView.h"

@interface HelpViewController ()<UITableViewDataSource, UITableViewDelegate,JFGSDKCallbackDelegate,UITextFieldDelegate> {
    BOOL needReport;//标记是否需要发送日志
    int64_t uploadLogTimestamp;
}
@property(nonatomic, strong)UITableView * _tableView;
@property(nonatomic, strong)NSMutableArray * chatArray;
@property(nonatomic, strong)UIView * bottomView;
@property(nonatomic, strong)InsetsTextField * inputTextF;
@property(nonatomic, strong)UIButton * sendButton;
@property(nonatomic, strong)UIImage * selfImage;

@end

@implementation HelpViewController
//[UIImage imageNamed:@"image_defaultHead"]
- (void)viewDidLoad {
    [super viewDidLoad];
    needReport = YES;//每一次进这个页面表示全新的一次报告，需要发送日志
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"FEEDBACK"];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.hidden = NO;
    [self setRightButtonImage:nil title:[JfgLanguage getLanTextStrByKey:@"Tap3_Feedback_Clear"] font:[UIFont systemFontOfSize:15]];
    //self.chatModel = [[LSChatModel alloc]init];
    //self.chatArray = [LSChatModel readModelArray];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //[self getAccountHeadImage];
    [self.view addSubview:self._tableView];
    [self.view sendSubviewToBack:self._tableView];
    [self.view addSubview:self.bottomView];
    [self._tableView reloadData];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
    [JFGSDK getFeedbackList];
    [self changeTableViewContentOffSetToBottom];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self changeTableViewContentOffSetToBottom];
}

- (void)viewDidDisappear:(BOOL)animated {
    [JFGSDK removeDelegate:self];
    [super viewDidDisappear:animated];
}


#pragma mark- 上传日志
-(void)uploadLogFile
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString * path1 = [path stringByAppendingPathComponent:@"jfgworkdic"];
    NSString *path2 = [path1 stringByAppendingPathComponent:@"smartCall_t.txt"];
    NSString *path3 = [path1 stringByAppendingPathComponent:@"smartCall_w.txt"];
    NSString *path4 = [path1 stringByAppendingPathComponent:@"userCall_t.txt"];
    [SSZipArchive createZipFileAtPath:[path stringByAppendingPathComponent:@"jfgworkdic.zip"] withFilesAtPaths:@[path2,path3,path4]];
    JFGSDKAcount *acc =[[LoginManager sharedManager] accountCache];
    NSString *account = acc.account;
    //company_vid  /log/[vid]/[account]
    
    [JFGSDK uploadFile:[path stringByAppendingPathComponent:@"jfgworkdic.zip"] toCloudFolderPath:[CommonMethod uplodUrlForLogWithAccount:account timestamp:uploadLogTimestamp]];
    // 输入时候，顶部bar消失了
}

-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result
{
    
}

#pragma mark - UITableViewDatasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSChatCell * cell = [LSChatCell tableCellWithTableView:tableView];
    cell.model = self.chatArray[indexPath.row];
    [cell.headerImageSelf jfg_setImageWithAccount:nil placeholderImage:[UIImage imageNamed:@"image_defaultHead"] refreshCached:NO completed:nil];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    LSChatModel * model = self.chatArray[indexPath.row];
//    return model.cellHeight;
    return [tableView fd_heightForCellWithIdentifier:@"talk" cacheByIndexPath:indexPath configuration:^(LSChatCell * cell) {
        cell.model = self.chatArray[indexPath.row];
    }];
}
#pragma mark 监听方法
- (void)keyboardChangeFrame :(NSNotification *)note{
    CGFloat time = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat endY = rect.origin.y;
    //内容的高度
    CGFloat contentSizeHeight =[self._tableView contentSize].height;
    //能显示,tableview最大的高度
    CGFloat valiableSizeHeight =self.view.height -64 -55;
    //键盘的高度
    CGFloat keyBoardHeight =kheight -endY;
    //内容与界面底部的间隔
    CGFloat marginHeight =valiableSizeHeight -contentSizeHeight;
    
    [UIView animateWithDuration:time animations:^{
//        [self._tableView setFrame:CGRectMake(0, 64 -(kheight -endY), Kwidth, self.view.height-64-55)];
        
        if (keyBoardHeight <5.f) {
            [self._tableView setFrame:CGRectMake(0, 64, Kwidth, valiableSizeHeight)];
        }else{
            if (marginHeight <0.f) {
                //内容的高度大于界面能显示的高度
                [self._tableView setFrame:CGRectMake(0, 64 -keyBoardHeight, Kwidth, valiableSizeHeight)];
            }else if (marginHeight >keyBoardHeight){
                //留下间隔的高度大于键盘的高度
                [self._tableView setFrame:CGRectMake(0, 64, Kwidth, valiableSizeHeight -keyBoardHeight)];
            }else{
                //留下的间隔小于键盘的高度
                [self._tableView setFrame:CGRectMake(0, 64 -(keyBoardHeight -marginHeight), Kwidth, valiableSizeHeight -marginHeight)];
            }
        }
        
        [self.bottomView setFrame:CGRectMake(0, endY -55, Kwidth, 55)];
    }];
    [self changeTableViewContentOffSetToBottom];
}
#pragma mark  - 滑到最底部
- (void)changeTableViewContentOffSetToBottom{
//        if (self._tableView.contentSize.height + 64 > self._tableView.frame.size.height) {
//            [self._tableView setContentOffset:CGPointMake(0, self._tableView.contentSize.height - CGRectGetHeight(self._tableView.frame) ) animated:YES];
//        }
//
    if (self.chatArray.count>0) {
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:[self.chatArray count] -1 inSection:0];
        
        [self._tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
#pragma mark - 自动回复
- (void)autoAnswer {
    
    NSDateFormatter *matter =[[NSDateFormatter alloc] init];
    [matter setDateFormat:@"yyyy/MM/dd hh:mm"];
    NSDictionary *msgDic = nil;
    if (self.chatArray.count == 0) {
        //此时代表是初次进入此ye
        msgDic =@{ @"msg"       :   [JfgLanguage getLanTextStrByKey:@"Tap3_Feedback_AutoTips"],
                                    @"msgDate"      :   [matter stringFromDate:[NSDate date]],
                                    @"lastMsgDate"  :   @"0",
                                    @"modelType"    :   @0
                                    };

    } else {
        LSChatModel *lastModel =[self.chatArray lastObject];
        
        NSDateFormatter *matter =[[NSDateFormatter alloc] init];
        [matter setDateFormat:@"yyyy/MM/dd hh:mm"];
        
        msgDic =@{ @"msg"       :   [JfgLanguage getLanTextStrByKey:@"Tap3_Feedback_AutoReply"],
                                    @"msgDate"      :   [matter stringFromDate:[NSDate date]],
                                    @"lastMsgDate"  :   lastModel.msgDate,
                                    @"modelType"    :   @0
                                    };
    }
    
    LSChatModel *aModel =[LSChatModel creatModel:msgDic];
    
    [self.chatArray addObject:aModel];
    
    NSMutableDictionary *writeDic =(NSMutableDictionary *)[aModel dictionaryWithValuesForKeys:@[@"msg",
                                                                                                @"msgDate",
                                                                                                @"lastMsgDate",
                                                                                                @"modelType",
                                                                                                @"cellHeight",
                                                                                                @"enableDateLabel"]];
    [[ LSBookManager sharedManager] writePlist:writeDic];
//    CGPoint p =self._tableView.contentOffset;
//    
//    [self._tableView setContentOffset:CGPointMake(p.x, p.y +aModel.cellHeight +72) animated:YES];
    
    [self._tableView reloadData];
    [self changeTableViewContentOffSetToBottom];
    
}
#pragma mark - UIButtonAction
- (void)leftButtonAction:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightButtonAction:(UIButton *)btn {
    if (self.chatArray.count > 0) {
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_Feedback_ClearTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_Feedback_Clear"] CancelBlock:^{
            
        } OKBlock:^{
            [[LSBookManager sharedManager] deletePlist];
            
            [self._tableView scrollsToTop];
            [self.chatArray removeAllObjects];
            [self._tableView reloadData];
        }];
    }
}
-(void)sendButtonAction:(UIButton *)sender{
    if (self.inputTextF.text.length >= 10) {
        
        LSChatModel *lastModel;
        NSString * lastModelDate;
        //上一条自己发送的内容
        LSChatModel * lastSelfModel = [self lastSelfModel];
        
        NSDateFormatter *matter =[[NSDateFormatter alloc] init];
        [matter setDateFormat:@"yyyy/MM/dd hh:mm"];

        if(self.chatArray.count == 0) {
            lastModelDate = [matter stringFromDate:[NSDate date]];
        } else {
            lastModel =[self.chatArray lastObject];
            lastModelDate = lastModel.msgDate;
            
        }
        NSDictionary *msgDic =@{    @"msg"          :   _inputTextF.text,
                                    @"msgDate"      :   [matter stringFromDate:[NSDate date]],
                                    @"lastMsgDate"  :   lastModelDate,
                                    @"modelType"    :   @1
                                };
        
        LSChatModel *aModel =[LSChatModel creatModel:msgDic];
        [self.chatArray addObject:aModel];
        
        
        
        NSMutableDictionary *writeDic =(NSMutableDictionary *)[aModel dictionaryWithValuesForKeys:@[@"msg",
                                                                      @"msgDate",
                                                                      @"lastMsgDate",
                                                                      @"modelType",
                                                                      @"cellHeight",
                                                                      @"enableDateLabel"]];
        
        [[LSBookManager sharedManager] writePlist:writeDic];
        //发给服务器
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval timestamp =[dat timeIntervalSince1970];
        uploadLogTimestamp = timestamp;
        [JFGSDK sendFeedbackWithTimestamp:uploadLogTimestamp content:self.inputTextF.text hasSendLog:needReport];
        //移动表格17102
    
        [self._tableView reloadData];
        [self changeTableViewContentOffSetToBottom];
        //如果这一条的消息比最后一条我的消息大于五分钟，将发送自动回复
        
        
        if ([[NSDate date] timeIntervalSince1970] - [[matter dateFromString:lastSelfModel.msgDate] timeIntervalSince1970] >= 300) {
            [self autoAnswer];
        }
        //提交日志
        if (needReport) {
            [self uploadLogFile];
            needReport = NO;//发送一次后，之后的对话无需再发送
        }
        self.inputTextF.text = @"";
        
    } else {
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap3_Feedback_TextFail"]];
    }
}
#pragma mark - JFGSDKCallBack
//未读的回复消息
-(void)jfgFeedBackWithInfoList:(NSArray <JFGSDKFeedBackInfo *> *)infoList errorType:(JFGErrorType)errorType {
    //NSLog(@"回复未读的消息列表打印：%@,错误信息：%d",infoList,errorType);
    NSDateFormatter *matter =[[NSDateFormatter alloc] init];
    [matter setDateFormat:@"yyyy/MM/dd hh:mm"];
    NSDictionary *msgDic = nil;
    for (JFGSDKFeedBackInfo * info in infoList) {
        LSChatModel *lastModel =[self.chatArray lastObject];
        
        msgDic =@{ @"msg"          :   info.msg,
                   @"msgDate"      :   [matter stringFromDate:[NSDate dateWithTimeIntervalSince1970:info.timestamp]],
                   @"lastMsgDate"  :   lastModel.msgDate,
                   @"modelType"    :   @0
                   };
        
        
        LSChatModel *aModel =[LSChatModel creatModel:msgDic];
        
        [self.chatArray addObject:aModel];
        
        NSMutableDictionary *writeDic =(NSMutableDictionary *)[aModel dictionaryWithValuesForKeys:@[@"msg",
                                                                                                    @"msgDate",
                                                                                                    @"lastMsgDate",
                                                                                                    @"modelType",
                                                                                                    @"cellHeight",
                                                                                                    @"enableDateLabel"]];
        [[LSBookManager sharedManager] writePlist:writeDic];
        [self._tableView reloadData];
        [self changeTableViewContentOffSetToBottom];

    }
    
}
//客户消息是否成功的回调
-(void)jfgSendFeedBackResult:(JFGErrorType)errorType {
    NSLog(@"反馈的消息错误信息：%d",errorType);
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (str.length>128) {
        return NO;
    }
    return YES;
}

-(void)textFieldValueChanged:(UITextField *)textField
{
    if (textField.text.length > 128) {
        
        self.inputTextF.text = [self.inputTextF.text substringToIndex:128];
    }
}

#pragma mark - OtherMethod
-(NSString *)dateString{
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString * dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

- (LSChatModel *)lastSelfModel {
    NSMutableArray * arr = [NSMutableArray array];
    for (LSChatModel * model in self.chatArray) {
        if (model.modelType == LSModelTypeMe) {
            [arr addObject:model];
        }
    }
    return [arr lastObject];
}
#pragma mark - UI
-(NSMutableArray *)chatArray{
    if (_chatArray == nil) {
        _chatArray =[NSMutableArray arrayWithArray:[LSChatModel allMsgModel]];
        if (_chatArray.count == 0) {
            [self autoAnswer];
        }
    }
    return _chatArray;
}
-(UITableView *)_tableView{
    if (!__tableView) {
        __tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64-55) style:UITableViewStylePlain];
        __tableView.delegate = self;
        __tableView.dataSource = self;
        __tableView.showsVerticalScrollIndicator = NO;
        __tableView.showsHorizontalScrollIndicator = NO;
        __tableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        __tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //__tableView.fd_debugLogEnabled = YES;
        [__tableView registerClass:[LSChatCell class] forCellReuseIdentifier:@"talk"];
    }
    return __tableView;
}
-(UIView *)bottomView{
    if (!_bottomView) {
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0.5)];
        line.backgroundColor = TableSeparatorColor;
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.height-55, self.view.width, 55)];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"#ebebeb"];
        [_bottomView addSubview:line];
        [_bottomView addSubview:self.inputTextF];
        [_bottomView addSubview:self.sendButton];
    }
    return _bottomView;
}
-(InsetsTextField *)inputTextF{
    if (!_inputTextF) {
        _inputTextF = [[InsetsTextField alloc]initWithFrame:CGRectMake(15, 10, self.view.width-75, 34)];
        _inputTextF.placeholder = [JfgLanguage getLanTextStrByKey:@"Tap3_Feedback_TextTips"];
        _inputTextF.font = [UIFont systemFontOfSize:14];
        [_inputTextF setValue:[UIColor colorWithHexString:@"#cecece"] forKeyPath:@"_placeholderLabel.textColor"];
        _inputTextF.backgroundColor = [UIColor whiteColor];
        _inputTextF.layer.cornerRadius = 5;
        _inputTextF.delegate = self;
        [_inputTextF addTarget:self action:@selector(textFieldValueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
        _inputTextF.layer.masksToBounds = YES;
    }
    return _inputTextF;
}
-(UIButton *)sendButton{
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(self.view.width-60, 0, 60, 55);
        [_sendButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_sendButton setTitle:[JfgLanguage getLanTextStrByKey:@"SEND"] forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
