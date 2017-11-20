//
//  YoutubeCreatChannelVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/6.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "YoutubeCreatChannelVC.h"
#import "FLTextView.h"
#import <Masonry.h>
#import "LiveDatePickerView.h"
#import "ProgressHUD.h"

@interface YoutubeCreatChannelVC ()<UITextViewDelegate,LiveDatePickerDelegate>
{
    BOOL isEditStartTime;
}

@property (nonatomic,strong)UIView *allBgView;
@property (nonatomic,strong)UILabel *title1Label;
@property (nonatomic,strong)FLTextView *titleTextView;
@property (nonatomic,strong)UILabel *descriptionLabel;
@property (nonatomic,strong)FLTextView *descroptionTextView;
@property (nonatomic,strong)TimeCell *startTimeCell;
@property (nonatomic,strong)TimeCell *endTimeCell;
@property (nonatomic,strong)UIButton *addOrDelCell;
@property (nonatomic,strong)UIView *currentTextFieldView;
@property (nonatomic,strong)UIButton *rightBtn;

@end

@implementation YoutubeCreatChannelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_CREATE_BUTTON"];
    [self initView];
    [self initNavagationView];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNoticeForKeyboard];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createChannelResult:) name:@"createChannelResult" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
    [self removeKeyBoradNotifacation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ProgressHUD dismiss];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

-(void)createChannelResult:(NSNotification *)notification
{
    NSError *error = notification.object;
    if (error) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_CREATE_FAIL_TIPS"]];
    }else{
        [ProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)initView
{
    [self.view addSubview:self.allBgView];
    [self.allBgView addSubview:self.title1Label];
    [self.allBgView addSubview:self.titleTextView];
    [self.allBgView addSubview:self.descriptionLabel];
    [self.allBgView addSubview:self.descroptionTextView];
    [self.allBgView addSubview:self.startTimeCell];
    [self.allBgView addSubview:self.addOrDelCell];
    [self.allBgView addSubview:self.endTimeCell];
    [self.topBarBgView addSubview:self.rightBtn];
    [self.view bringSubviewToFront:self.topBarBgView];
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



-(void)timeSelectedAction:(UIControl *)sender
{
    LiveDatePickerView *pickerView = [[LiveDatePickerView alloc]initWithDelegate:self];
    if (sender.tag == 10001) {
        //结束时间
        isEditStartTime = NO;
        pickerView.minimumDate = self.startTimeCell.selectedDate?self.startTimeCell.selectedDate:[NSDate date];
    }else{
        //开始时间
        isEditStartTime = YES;
        if (self.endTimeCell.selectedDate) {
            pickerView.maximumDate = self.endTimeCell.selectedDate;
        }
    }
    [pickerView show];
}

-(void)doneAction
{
    NSString *title = [self.titleTextView.text isEqualToString:@""]?self.titleTextView.placeholder:self.titleTextView.text;
    NSString *detail = [self.descroptionTextView.text isEqualToString:@""]?self.descroptionTextView.placeholder:self.descroptionTextView.text;
   
    if (self.youtubeHelper) {
        [self.youtubeHelper createLiveChannelWithTitle:title description:detail startTime:self.startTimeCell.selectedDate endTime:self.endTimeCell.selectedDate cid:self.cid];
        [ProgressHUD showProgress:[JfgLanguage getLanTextStrByKey:@"LIVE_CHANNEL_CREATING_LOADING"]];
    }
}

#pragma mark- delegate
-(void)pickerSelectedDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *str = [dateFormatter stringFromDate:date];
    if (isEditStartTime) {
        self.startTimeCell.selectedDate = date;
        self.startTimeCell.detailLabel.text = str;
    }else{
        self.endTimeCell.selectedDate = date;
        self.endTimeCell.detailLabel.text = str;
    }
}

#pragma mark- textViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.currentTextFieldView = textView;
    return YES;
}

#pragma mark - 键盘通知
- (void)addNoticeForKeyboard {
    
    //注册键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    //注册键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)removeKeyBoradNotifacation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark- 键盘监控通知
///键盘显示事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    //获取视图相对于self.view的坐标
    CGRect rc = [self.currentTextFieldView.superview convertRect:self.currentTextFieldView.frame toView:self.view];
    
    CGFloat offset = rc.origin.y+rc.size.height+kbHeight-self.view.height;
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.allBgView.top = 64-offset;
        }];
    }else{
        [UIView animateWithDuration:duration animations:^{
            self.allBgView.top = 64;
        }];
    }

}

///键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notify {
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.allBgView.top = 64;
    }];
}


-(UIView *)allBgView
{
    if (!_allBgView) {
        _allBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        _allBgView.backgroundColor = [UIColor colorWithHexString:@"#F0F0F0"];
    }
    return _allBgView;
}

-(UILabel *)title1Label
{
    if (!_title1Label) {
        _title1Label = [[UILabel alloc]initWithFrame:CGRectMake(16, 20, 100, 14)];
        _title1Label.font = [UIFont systemFontOfSize:13];
        _title1Label.textColor = [UIColor colorWithHexString:@"#888888"];
        _title1Label.text = [JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_TITLE"];
    }
    return _title1Label;
}

-(FLTextView *)titleTextView
{
    if (!_titleTextView) {
        _titleTextView = [self factoryTextViewForFrame:CGRectMake(0, 44, self.view.width, 120) placeholder:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"]];
    }
    return _titleTextView;
}

-(UILabel *)descriptionLabel
{
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 185, 100, 14)];
        _descriptionLabel.font = [UIFont systemFontOfSize:13];
        _descriptionLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        _descriptionLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DESCRIPTION"];
    }
    return _descriptionLabel;
}

-(FLTextView *)descroptionTextView
{
    if (!_descroptionTextView) {
        _descroptionTextView = [self factoryTextViewForFrame:CGRectMake(0, 208, self.view.width, 120) placeholder:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"]];
    }
    return _descroptionTextView;
}

-(TimeCell *)startTimeCell
{
    if (!_startTimeCell) {
        _startTimeCell = [[TimeCell alloc]initWithFrame:CGRectMake(0, 349, self.view.width, 44)];
        _startTimeCell.tag = 10000;
        [_startTimeCell addTarget:self action:@selector(timeSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startTimeCell;
}

-(TimeCell *)endTimeCell
{
    if (!_endTimeCell) {
        _endTimeCell =[[TimeCell alloc]initWithFrame:CGRectMake(0, 393, self.view.width, 44)];
        _endTimeCell.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"TO"];
        _endTimeCell.hidden = YES;
        _endTimeCell.tag = 10001;
        [_endTimeCell addTarget:self action:@selector(timeSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endTimeCell;
}



-(void)addOrDelCell:(UIButton *)btn
{
    if (self.endTimeCell.hidden) {
        
        self.endTimeCell.alpha = 0;
        self.endTimeCell.hidden = NO;
        [self.addOrDelCell setTitle:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEL_END_TIME"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            self.addOrDelCell.top = 455;
            self.endTimeCell.alpha = 1;
        }];
        
    }else{
       
        [UIView animateWithDuration:0.2 animations:^{
            self.endTimeCell.alpha = 0;
        } completion:^(BOOL finished) {
            self.endTimeCell.hidden = YES;
            self.endTimeCell.detailLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_SET"];
            self.endTimeCell.selectedDate = nil;
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.addOrDelCell.top = 410;
            [self.addOrDelCell setTitle:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_ADD_END_TIME"] forState:UIControlStateNormal];
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}

-(UIButton *)addOrDelCell
{
    if (!_addOrDelCell) {
        _addOrDelCell = [UIButton buttonWithType:UIButtonTypeCustom];
        _addOrDelCell.frame = CGRectMake(15, 410, 100, 17);
        [_addOrDelCell setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
        [_addOrDelCell setTitle:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_ADD_END_TIME"] forState:UIControlStateNormal];
        _addOrDelCell.titleLabel.textAlignment = NSTextAlignmentLeft;
        _addOrDelCell.titleLabel.font = [UIFont systemFontOfSize:16];
        [_addOrDelCell addTarget:self action:@selector(addOrDelCell:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addOrDelCell;
}

-(UITableViewCell *)factoryCellWithFrame:(CGRect)frame text:(NSString *)text detail:(NSString *)detail
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@""];
    cell.frame = frame;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    cell.textLabel.text =text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = detail;
    return cell;
}

-(FLTextView *)factoryTextViewForFrame:(CGRect)frame placeholder:(NSString *)placeholder
{
    FLTextView *_rtmpTextView = [[FLTextView alloc]initWithFrame:frame];
    CGFloat xMargin = 15, yMargin = 15;//左右，上下边距
    // 使用textContainerInset设置top、left、right
    _rtmpTextView.textContainerInset = UIEdgeInsetsMake(yMargin, xMargin, 0, xMargin);
    //当光标在最后一行时，始终显示低边距，需使用contentInset设置bottom.
    _rtmpTextView.contentInset = UIEdgeInsetsMake(0, 0, yMargin, 0);
    //防止在拼音打字时抖动
    _rtmpTextView.layoutManager.allowsNonContiguousLayout=NO;
    _rtmpTextView.font = [UIFont systemFontOfSize:14];
    _rtmpTextView.placeholder = placeholder;
    _rtmpTextView.placeholderFont = [UIFont systemFontOfSize:14];
    _rtmpTextView.placeholderColor = [UIColor colorWithHexString:@"#CECECE"];
    _rtmpTextView.placeholderPoint = [NSValue valueWithCGPoint:CGPointMake(18, 15)];
    _rtmpTextView.textColor = [UIColor colorWithHexString:@"#666666"];
    _rtmpTextView.delegate = self;
    return _rtmpTextView;
}

-(UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 32, 50, 20);
        _rightBtn.right = self.view.width - 10;
        _rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rightBtn setTitle:[JfgLanguage getLanTextStrByKey:@"OK"] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
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



@implementation TimeCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    [self initView];
    return self;
}

-(void)initView
{
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailLabel];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"me_icon_list_next"]];
    imageView.right = self.width-15;
    imageView.y = self.height*0.5;
    [self addSubview:imageView];
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, 50, 20)];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.text = [JfgLanguage getLanTextStrByKey:@"FROME"];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

-(UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 12, 50, 20)];
        _detailLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.width = ceil(self.width - self.titleLabel.right - 37)-10;
        _detailLabel.right = self.width-37;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_SET"];
    }
    return _detailLabel;
}



@end

