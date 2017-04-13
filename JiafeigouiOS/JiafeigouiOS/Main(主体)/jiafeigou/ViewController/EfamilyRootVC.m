//
//  EfamilyRootVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "EfamilyRootVC.h"
#import "EfamilyLeftCell.h"
#import "EfamilyRightCell.h"
#import "EfamilyVoiceCell.h"
#import "EfamilyBottomView.h"
#import "EfamilyRecordView.h"
#import "VideoChatVC.h"
#import "DeviceSettingVC.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDK.h>
#import "JFGEfamilyDataManager.h"
#import "LoginManager.h"
#import "JfgGlobal.h"

const CGFloat animationDuration = 0.3f;

@interface EfamilyRootVC ()<AVAudioRecorderDelegate, JFGSDKCallbackDelegate,AVAudioPlayerDelegate>
{
    /**
     *  倒计时 定时器
     */
    NSTimer *_recordTimer;
    /**
     *  音波 定时器
     */
    NSTimer *_voiceTimer;
    /**
     *  录音 时间
     */
    CGFloat _recordTime;
    
    /**
     *  当前偏移量
     */
    CGFloat _currentOffset;
    
    
    NSString *currentRecordVoicePath;
    
    int64_t startRecordVoiceTimestamp;
    
    NSIndexPath *currentPlayingIndexPath;
}
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UITableView *efamilyTableView;

@property (nonatomic, strong) EfamilyRootViewModel *efamilyToorVM;

@property (nonatomic,copy)NSString *filePath;

/**
 *  底部 功能按钮
 */
@property (nonatomic, strong) EfamilyBottomView *bottomView;
/**
 *  录音界面 view
 */
@property (nonatomic, strong) EfamilyRecordView *recordView;
/**
 *  录音
 */
@property (nonatomic, strong) AVAudioRecorder *audioRecord;


@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;

@property (strong, nonatomic) UIView * noDataView;
@end

@implementation EfamilyRootVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigationView];
    [JFGSDK addDelegate:self];
    
    _recordTime = 60.0;
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (self.avAudioPlayer) {
        [self.avAudioPlayer stop];
        
    }
    if (currentPlayingIndexPath.row < self.dataArray.count) {
        
        JFGEfamilyDataModel *model = self.dataArray[currentPlayingIndexPath.row];
        model.isPlaying = NO;
        EfamilyVoiceCell *cell = [self.efamilyTableView cellForRowAtIndexPath:currentPlayingIndexPath];
        if ([cell isKindOfClass:[EfamilyVoiceCell class]]) {
            [cell.voiceImageView stopAnimating];
        }
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSArray *data = [[JFGEfamilyDataManager defaultEfamilyManager] getEfamilyMsgListForCid:self.cid];
    
    [self tableViewData:data isScrollToBottom:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark view
- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f9f9f9"];
    
    [self.view addSubview:self.efamilyTableView];
    
    [self.view addSubview:self.noDataView];
    
    [self.view addSubview:self.bottomView];
    
    [self.view addSubview:self.recordView];
    
    [self judgeHaveData];
    
}

- (void)initNavigationView
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.hidden = NO;
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"DOOR_MAGNET_NAME"];
}

#pragma mark animation
- (void)scrollOffsetAnimation:(BOOL)isUp
{
    if (self.efamilyTableView.contentSize.height > self.efamilyTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.efamilyTableView.contentSize.height - self.efamilyTableView.frame.size.height);
        [self.efamilyTableView setContentOffset:offset animated:YES];
    }
    
    
//    CGFloat offset = self.recordView.height - self.bottomView.height; //需要偏移的大小
//    
//    [UIView animateWithDuration:animationDuration animations:^{
//        if (isUp) // 往上升起
//        {
//            self.efamilyTableView.contentOffset = CGPointMake(0, _currentOffset + offset);
//        }
//        else
//        {
//            self.efamilyTableView.contentOffset = CGPointMake(0, _currentOffset - offset);
//        }
//    } completion:^(BOOL finished) {
//        
//    }];
}

#pragma mark  data
- (void)tableViewData:(NSArray *)data isScrollToBottom:(BOOL)isBotttom
{
    if (self.dataArray != data)
    {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:data];

    }
    if (isBotttom)
    {
        [self scrollToBottom:nil];
    }
    [self judgeHaveData];
}

#pragma mark timer

- (void)startRecordTimer
{
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(recordTimerAction:) userInfo:nil repeats:YES];
}
- (void)endRecordTimer
{
    if (_recordTimer)
    {
        if ([_recordTimer isValid])
        {
            [_recordTimer invalidate];
        }
        _recordTimer = nil;
    }
    
    self.recordView.animatinLine.frame = CGRectMake(0, self.recordView.animatinLine.top, Kwidth, self.recordView.animatinLine.height);
    self.recordView.recordButton.enabled = YES;
    _recordTime = 60;
    
}

- (void)recordTimerAction:(NSTimer *)timer
{
    _recordTime -= 0.1;
    CGFloat changWidth = _recordTime/60.0 * Kwidth;
    CGFloat changeX = (Kwidth - changWidth)/2.0;
    
    if (_recordTime == 0)
    {
        self.recordView.recordButton.enabled = NO;
    }
    
    self.recordView.animatinLine.frame = CGRectMake(changeX, self.recordView.animatinLine.top, changWidth, self.recordView.animatinLine.height);
}

// 开启 音频检测
- (void)startDetectionVoice
{
    _voiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}
// 停止 音频检测
- (void)stopDetectionVoice
{
    if (_voiceTimer)
    {
        if ([_voiceTimer isValid])
        {
            [_voiceTimer invalidate];
        }
        _voiceTimer = nil;
        
        self.recordView.leftImageView.image = [UIImage imageNamed:@"efamily_voice_0.png"];
        self.recordView.rightImageView.image = [UIImage imageNamed:@"efamily_voice_0.png"];
    }
}

// 语音检测
- (void)detectionVoice
{
    
    [self.audioRecord updateMeters];//刷新音量数据
    
    double lowPassResults = pow(10, (0.05 * [self.audioRecord peakPowerForChannel:0]));
    
    //最大50  0
    if( 0 < lowPassResults  && lowPassResults <= 0.03)
    {
        self.recordView.leftImageView.image = [UIImage imageNamed:@"efamily_voice_0.png"];
        self.recordView.rightImageView.image = [UIImage imageNamed:@"efamily_voice_0.png"];
    }
    else if (lowPassResults > 0.03 && lowPassResults <= 0.33 )
    {
        self.recordView.leftImageView.image = [UIImage imageNamed:@"efamily_voice_1.png"];
        self.recordView.rightImageView.image = [UIImage imageNamed:@"efamily_voice_1.png"];
    }
    else if (0.33 < lowPassResults && lowPassResults<= 0.66)
    {
        self.recordView.leftImageView.image = [UIImage imageNamed:@"efamily_voice_2.png"];
        self.recordView.rightImageView.image = [UIImage imageNamed:@"efamily_voice_2.png"];
    }
    else
    {
        self.recordView.leftImageView.image = [UIImage imageNamed:@"efamily_voice_3.png"];
        self.recordView.rightImageView.image = [UIImage imageNamed:@"efamily_voice_3.png"];
    }
}

#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)rightButtonAction:(UIButton *)sender
{
    DeviceSettingVC *deviceSetting = [DeviceSettingVC new];
    deviceSetting.pType = productType_Efamily;
    deviceSetting.isShare = self.isShare;
    deviceSetting.cid = self.cid;
    [self.navigationController pushViewController:deviceSetting animated:YES];
}

- (void)shareImageButtonAction:(UIButton *)sender
{
    JFGLog(@"敬请期待");
    
    [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"EXPECT"] position:FLProgressHUDPositionCenter];
    [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1];
    
   //[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:15646], @"mId", self.cid, @"cid", @0, @"time", nil];
    
//    [JFGSDK sendEfamilyMsg:@""];
    
}

- (void)videoChatButtonAction:(UIButton *)sender
{
    JFGLog(@"跳转 videoChat");
    VideoChatVC *videoChat = [VideoChatVC new];
    videoChat.chatType = videoChatTypeActive;
    videoChat.cid = self.cid;
    NSDate *cuDate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:cuDate];
    NSDate *localeDate = [cuDate dateByAddingTimeInterval:interval];
    videoChat.timeStamp = [localeDate timeIntervalSince1970];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:videoChat];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)voiceButtonAction:(UIButton *)sender
{
    [self.recordView showAnimationWithDuration:animationDuration];
    [self scrollOffsetAnimation:YES];
    JFGLog(@"语音留言");
}

#pragma mark record action
- (void)recordButtonDown:(UIButton *)sender
{
    [self startRecordTimer];
    [self startDetectionVoice];
    [self startRecord];
}

- (void)recordButtonUp:(UIButton *)sender
{
    [self endRecordTimer];
    [self stopDetectionVoice];
    [self.audioRecord stop];
    [self saveVoice];
}

- (void)recordButtonOutsideUp:(UIButton *)sender
{
    [self endRecordTimer];
    [self stopDetectionVoice];
    [self.audioRecord stop];
    [self saveVoice];
}


#pragma mark- 录音结束操作
-(void)saveVoice
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.filePath]) {
        
        long timeBegin = (long)[[[self.filePath lastPathComponent] stringByDeletingPathExtension] longLongValue];
        
        //NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:timeBegin];
        
        
        NSDate *cuDate = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:cuDate];
        NSDate *localeDate = [cuDate dateByAddingTimeInterval:interval];
        long cutime = [localeDate timeIntervalSince1970];
        
//        NSCalendar *cal = [NSCalendar currentCalendar];
//        
//        unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
//        
//        NSDateComponents *d = [cal components:unitFlags fromDate:localeDate toDate:[NSDate dateWithTimeIntervalSince1970:timeBegin] options:0];
//        int secred = d.second;
        
        //double timeInterval = [beginDate timeIntervalSinceDate:[NSDate date]];
        int timeInterval = abs(cutime-timeBegin);
        int seconds = (timeInterval)%(3600*24)%3600%60;
        
        if (seconds>2) {
    
            NSString *filePath = [[self.filePath stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"_%d.caf", seconds]];
            NSError *error = nil;
            
            BOOL isSuccess =[fileManager moveItemAtPath:self.filePath toPath:filePath error:&error];
            
            if (!isSuccess || error) {
                
                NSLog(@"fileError:%@",error.description);
                
            }
            
            int requestId = [JFGSDK httpPostWithReqPath:[NSString stringWithFormat:@"/index.php?mod=client&act=voiceMsg&timeBegin=%ld&timeDuration=%d&cid=%@&sessid=%@", timeBegin, seconds, self.cid,[JFGSDK getSession]] filePath:filePath];
            NSLog(@"requestId:%d",requestId);
            
            JFGEfamilyDataModel *model = [JFGEfamilyDataModel new];
            model.isFromSelf = YES;
            model.acceptSuccess = YES;
            model.timestamp = timeBegin;
            model.timeLength = seconds;
            model.resourceUrl = filePath;
            model.msgType = JFGEfamilyMsgTypeVoice;
            model.cid = self.cid;
            [[JFGEfamilyDataManager defaultEfamilyManager] addEfamilyMsg:model];
            NSLog(@"保存录音");
            
            
            NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:model.timestamp];
            NSLog(@"%@",beginDate.description);
            
            NSArray *data = [[JFGEfamilyDataManager defaultEfamilyManager] getEfamilyMsgListForCid:self.cid];
            [self tableViewData:data isScrollToBottom:YES];
        }
        
    }
    
}


-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result
{
    NSLog(@"httpResult:%@",result);
}

-(NSString *)filePathForCurrentUser:(NSString *)folderName cid:(NSString *)cidStr
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    JFGSDKAcount *acc =[[LoginManager sharedManager] accountCache];
    NSString *account = acc.account;
    NSString *documentsDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:account];
    if (cidStr) {
        documentsDir = [documentsDir stringByAppendingPathComponent:cidStr];
    }
    if (folderName) {
        documentsDir = [documentsDir stringByAppendingPathComponent:folderName];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:documentsDir]){
        [fileManager createDirectoryAtPath:documentsDir  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return documentsDir;
}

- (void)recordExitButtonAction:(UIButton *)sender
{
    [self scrollOffsetAnimation:NO];
}

- (void)startRecord
{
    NSError *audioSessionError = nil;
    NSError *audioRecordError = nil;
    
    NSMutableDictionary *recorderSetting = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                            [NSNumber numberWithFloat:44100.0], AVSampleRateKey,//设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
                                            [NSNumber numberWithInt:1], AVNumberOfChannelsKey,//录音通道数  1 或 2
                                            [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,//录音的质量
                                            [NSNumber numberWithInt:AVAudioQualityMin], AVSampleRateConverterAudioQualityKey,
                                            [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                            nil];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];
    [audioSession setActive: YES error: nil];
    if(audioSessionError)
    {
        JFGLog(@"AVAudioSession Error: %@",[audioSessionError description]);
    }
    
//    NSString *filePath = [[StaticMethods filePathForCurrentUser:MESSAGE_PATH cid:[NSString stringWithFormat:@"%@",self.cidString]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.caf", (long)([[NSDate date] timeIntervalSince1970] - ntpTimeError)]];

    
    int64_t timestamp = [[NSDate date] timeIntervalSince1970];
    startRecordVoiceTimestamp = timestamp;
    currentRecordVoicePath = [NSString stringWithFormat:@"%lld",timestamp];
    
    long ntpTimeError;
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:JFGSDKNTPTIMESTAMP];
    if (num) {
        ntpTimeError = [num longValue];
    }else{
        ntpTimeError = 0;
    }
    
    self.filePath = [self filePathForCurrentUser:@"message" cid:self.cid];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.filePath]) {
        
        [fileManager createDirectoryAtPath:self.filePath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    NSDate *cuDate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:cuDate];
    NSDate *localeDate = [cuDate  dateByAddingTimeInterval: interval];
    self.filePath = [self.filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.caf", (long)[localeDate timeIntervalSince1970]]];
    NSLog(@"self.filePath:%@",self.filePath);
    
    self.audioRecord = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.filePath] settings:recorderSetting error:&audioRecordError];
    
    if (audioRecordError)
    {
        JFGLog(@"audioRecorder Error: %@",[audioSessionError description]);
    }
    else
    {
        if ([self.audioRecord prepareToRecord])
        {
            [self.audioRecord record];
            //开启音量检测
            self.audioRecord.meteringEnabled = YES;
            self.audioRecord.delegate = self;
            JFGLog(@"开始录音。。。");
        }
    }
}


-(NSString *)voicePathWithTimestamp:(int64_t)timestamp
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    JFGSDKAcount *acc =[[LoginManager sharedManager] accountCache];
    NSString *account = acc.account;

    NSString *p ;
    if (account) {
        p = [NSString stringWithFormat:@"%@/%@",account,self.cid];
    }else{
        p = [NSString stringWithFormat:@"%@",self.cid];
    }
    
    path = [path stringByAppendingPathComponent:p];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.caf",timestamp]];

    return path;
}

- (void)stopRecord:(BOOL)isSend
{
    
}
- (void)judgeHaveData {
    if (self.dataArray.count == 0) {
        self.noDataView.hidden = NO;
        self.efamilyTableView.hidden = YES;
    }else{
        self.noDataView.hidden = YES;
        self.efamilyTableView.hidden = NO;
        [self.efamilyTableView reloadData];
    }
}
#pragma mark TableViewdelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JFGEfamilyDataModel *model = [self.dataArray objectAtIndex:indexPath.row];
    model.indexPath = indexPath;
    cellType msgType;
    if (model.isFromSelf) {
        if (model.msgType == JFGEfamilyMsgTypeVoice) {
            msgType = cellTypeLeaveMsg;
        }else{
            msgType = cellTypeClientCall;
        }
    }else{
        msgType = cellTypeEfamilyCall;
    }
    
    BOOL isOK = model.acceptSuccess;

    NSString *time = [self stringFromTimestamp:model.timestamp];
    
    switch (msgType)
    {
        case cellTypeLeaveMsg:
        {
            static NSString *identifierCell = @"EfamilyVoiceCell";
            EfamilyVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell];
            if (!cell)
            {
                cell = [[EfamilyVoiceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.voiceDuraLabel.text = [self stringVoiceInterval:model.timeLength];
            cell.timeLabel.text = time;
            if (model.isPlaying) {
                [cell.voiceImageView startAnimating];
            }else{
                [cell.voiceImageView stopAnimating];
            }
            return cell;
        }
            break;
        case cellTypeClientCall:
        {
            static NSString *identifierCell = @"clientActionCell";
            EfamilyRightCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell];
            if (!cell)
            {
                cell = [[EfamilyRightCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.timeLabel.text = time;
            cell.contentsLabel.text = isOK ? [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_iHome_CallDuration"],[self stringCallInterval:model.timeLength]] : [JfgLanguage getLanTextStrByKey:@"DOOR_UNCALL"];
            cell.iconImageView.image = [UIImage imageNamed:isOK?@"efamily_cell_answer_icon_right":@"efamily_cell_holeon_icon"];
            
            return cell;
        }
            break;
        case cellTypeEfamilyCall:
        default:
        {
            static NSString *identifierCell = @"EfamilyLeftCell";
            EfamilyLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell];
            if (!cell)
            {
                cell = [[EfamilyLeftCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.timeLabel.text = time;
            cell.nickNameLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_MENU_VIDEOCALL"];
            cell.contentsLabel.text = isOK ? [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_iHome_CallDuration"],[self stringCallInterval:model.timeLength]] : [JfgLanguage getLanTextStrByKey:@"EFAMILY_MISSED_CALL"];
            cell.contentsLabel.textColor = isOK?RGBACOLOR(110, 110, 110, 1):RGBACOLOR(255, 23, 68, 1);
            cell.iconImageView.image = [UIImage imageNamed:isOK?@"":@"efamily_cell_redholeon_icon"];
            
            return cell;
        }
            break;
        
    }
}


-(NSString *)stringFromTimestamp:(int64_t)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatte = [[NSDateFormatter alloc]init];
    [dateFormatte setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatte setDateFormat:@"MM-dd HH:mm"];
    NSString *str = [dateFormatte stringFromDate:date];
    return str;
}

-(NSString *)stringCallInterval:(int64_t)interval
{
//    int days = (interval)/(3600*24);
//    
//    int hours = (interval)%(3600*24)/3600;
    int minutes = (interval)%(3600*24)%3600/60;
    int seconds = (interval)%(3600*24)%3600%60;
    
    NSString *str = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
    return str;
}

-(NSString *)stringVoiceInterval:(int64_t)interval
{
    int seconds = (interval)%(3600*24)%3600%60;
    NSString *str = [NSString stringWithFormat:@"%d″",seconds];
    return str;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did");
    JFGEfamilyDataModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cellType msgType;
    if (model.isFromSelf) {
        if (model.msgType == JFGEfamilyMsgTypeVoice) {
            msgType = cellTypeLeaveMsg;
        }else{
            msgType = cellTypeClientCall;
        }
    }else{
        msgType = cellTypeEfamilyCall;
    }
    //是否接听
    BOOL isOK = model.acceptSuccess;
    
    if (msgType == cellTypeEfamilyCall) {
        
        if (isOK) {
            VideoChatVC *videoChat = [VideoChatVC new];
            videoChat.chatType = videoChatTypeActive;
            videoChat.cid = self.cid;
            NSDate *cuDate = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate:cuDate];
            NSDate *localeDate = [cuDate dateByAddingTimeInterval:interval];
            videoChat.timeStamp = [localeDate timeIntervalSince1970];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:videoChat];
            nav.navigationBarHidden = YES;
            [self presentViewController:nav animated:YES completion:^{
               //
            }];
        }
       
        
    }else if (msgType == cellTypeLeaveMsg){
        
        NSString *filePath = [self filePathForCurrentUser:@"message" cid:self.cid];
        filePath = [filePath stringByAppendingPathComponent:[model.resourceUrl lastPathComponent]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            
            if (self.avAudioPlayer) {
                 [self.avAudioPlayer pause];
            }
            
            
            for (JFGEfamilyDataModel *_model in self.dataArray) {
                
                if (_model.isPlaying && _model.timestamp != model.timestamp) {
                    
                    _model.isPlaying = NO;
                    EfamilyVoiceCell *cell = [tableView cellForRowAtIndexPath:_model.indexPath];
                    [cell.voiceImageView stopAnimating];

                }
                
            }
            
            
            NSURL * fileUrl = [NSURL fileURLWithPath:filePath]; // 播放本地文件
           //初始化音频类 并且添加播放文件
            self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
            //设置代理
            self.avAudioPlayer.delegate = self;
            
            //设置初始音量大小
            self.avAudioPlayer.volume = 1;
            //设置音乐播放次数  -1为一直循环
            //_avAudioPlayer.numberOfLoops = 0;
            //预播放
            [self.avAudioPlayer prepareToPlay];
            [self.avAudioPlayer play];
            currentPlayingIndexPath = indexPath;
            model.isPlaying = YES;
            
            EfamilyVoiceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell.voiceImageView startAnimating];
            
        }
        
    }

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (currentPlayingIndexPath.row < self.dataArray.count) {
        
        JFGEfamilyDataModel *model = self.dataArray[currentPlayingIndexPath.row];
        model.isPlaying = NO;
        EfamilyVoiceCell *cell = [self.efamilyTableView cellForRowAtIndexPath:currentPlayingIndexPath];
        if ([cell isKindOfClass:[EfamilyVoiceCell class]]) {
            [cell.voiceImageView stopAnimating];
        }
        
    }
    [self.avAudioPlayer stop];
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _currentOffset = scrollView.contentOffset.y;
}

- (void)scrollToBottom:(UIScrollView *)scrollView
{
    
    if (self.efamilyTableView.contentSize.height <= self.efamilyTableView.height) {
        [self.efamilyTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    
    CGFloat offset = self.efamilyTableView.contentSize.height - self.efamilyTableView.height;
    offset = fabs(offset);
    [self.efamilyTableView setContentOffset:CGPointMake(0, offset) animated:YES];
}


#pragma mark vm  delegate

- (void)fetchDataArray:(NSArray *)fetchArray
{
    //[self tableViewData:fetchArray isScrollToBottom:YES];
}

- (void)updatedDataArray:(NSArray *)updatedArray{}
- (void)addDataWithArray:(NSArray *)addArray{}

#pragma mark property
-(UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-140)/2.0, 0.25*kheight, 140, 140)];
        iconImageView.image = [UIImage imageNamed:@"png-no-message"];
        [_noDataView addSubview:iconImageView];
        UILabel * noShareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImageView.bottom+20, Kwidth, 15)];
        noShareLabel.font = [UIFont systemFontOfSize:15];
        noShareLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        noShareLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_MESSAGE"];
        noShareLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:noShareLabel];
    }
    return _noDataView;
}
- (UITableView *)efamilyTableView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = kheight - 64 - self.bottomView.height;
    CGFloat widgetX = 0;
    CGFloat widgetY = 64;
    
    if (_efamilyTableView == nil)
    {
        _efamilyTableView = [[UITableView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight) style:UITableViewStyleGrouped];
        
        _efamilyTableView.delegate = self;
        _efamilyTableView.dataSource = self;
        _efamilyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _efamilyTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    }
    
    return _efamilyTableView;
}

- (EfamilyBottomView *)bottomView
{
    CGFloat widgetWidth = 0;// 设置无效
    CGFloat widgetHeight = 0;// 设置无效
    CGFloat widgetX = 0;// 设置无效
    CGFloat widgetY = kheight;
    if (_bottomView == nil)
    {
        _bottomView = [[EfamilyBottomView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        [_bottomView.shareImgeButton addTarget:self action:@selector(shareImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView.voiceButton addTarget:self action:@selector(voiceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView.videChatButton addTarget:self action:@selector(videoChatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _bottomView;
}

- (EfamilyRecordView *)recordView
{
    if (_recordView == nil)
    {
        _recordView = [[EfamilyRecordView alloc] initWithFrame:CGRectZero];
        [_recordView.recordButton addTarget:self action:@selector(recordButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [_recordView.recordButton addTarget:self action:@selector(recordButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_recordView.recordButton addTarget:self action:@selector(recordButtonOutsideUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_recordView.exitButton addTarget:self action:@selector(recordExitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordView;
}

- (AVAudioRecorder *)audioRecord
{
    if (_audioRecord == nil)
    {
        NSError *audioSessionError = nil;
        NSError *audioRecordError = nil;
        
        NSMutableDictionary *recorderSetting = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                                [NSNumber numberWithFloat:44100.0], AVSampleRateKey,//设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
                                                [NSNumber numberWithInt:1], AVNumberOfChannelsKey,//录音通道数  1 或 2
                                                [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,//录音的质量
                                                [NSNumber numberWithInt:AVAudioQualityMin], AVSampleRateConverterAudioQualityKey,
                                                [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                                nil];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];
        [audioSession setActive:YES error: nil];
        
        NSString *path = [NSString stringWithFormat:@"%@/temp.caf", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
        _audioRecord = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:recorderSetting error:&audioRecordError];
    }
    return _audioRecord;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] init];
    }
    
    return _dataArray;
}

- (EfamilyRootViewModel *)efamilyToorVM
{
    if (_efamilyToorVM == nil)
    {
        _efamilyToorVM = [[EfamilyRootViewModel alloc] init];
        _efamilyToorVM.efamilyRootDelegate = self;
    }
    
    return _efamilyToorVM;
}


@end
