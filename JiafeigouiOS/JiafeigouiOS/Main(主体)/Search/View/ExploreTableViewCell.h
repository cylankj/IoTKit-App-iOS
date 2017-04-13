//
//  ExploreTableViewCell.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/5/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLineView.h"
#import "DelButton.h"
#import "ExploreImageView.h"

@interface ExploreShareButton : UIButton

@end

@interface ExploreTableViewCell : UITableViewCell

@property (strong,nonatomic)NSIndexPath *_indexPath;
@property (nonatomic,copy)NSString *msgTime;

//cell0
@property (weak, nonatomic) IBOutlet TimeLineView *timeLineView;
@property (weak, nonatomic) IBOutlet UIImageView *timeLineCircleImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLineTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromDeviceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet DelButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) IBOutlet ExploreShareButton *shareButton;


//cell1
@property (weak, nonatomic) IBOutlet ExploreImageView *photoImageView;
@property (weak, nonatomic) IBOutlet TimeLineView *timeLineView1;
@property (weak, nonatomic) IBOutlet UIImageView *timeLineCircleImageView1;
@property (weak, nonatomic) IBOutlet UILabel *timeLineTimeLabel1;
@property (weak, nonatomic) IBOutlet DelButton *deleteButton1;
@property (weak, nonatomic) IBOutlet UILabel *fromDeviceLabel1;
@property (weak, nonatomic) IBOutlet ExploreShareButton *shareButton1;



@end




