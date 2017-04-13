//
//  ContactCell.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface ContactBtn : UIButton

@property (nonatomic,copy)NSString *phoneNumber;
@property (nonatomic,strong)NSIndexPath *_indexPath;
@property (nonatomic,assign)BOOL isSearchBar;

@end

/**
 *  此Cell 有复用 修改的需注意
 *
 *  @param nonatomic <#nonatomic description#>
 *  @param strong    <#strong description#>
 *
 *  @return <#return value description#>
 */

@interface ContactCell : UITableViewCell
@property (nonatomic, strong)UILabel * nameLabel;
@property (nonatomic, strong)UILabel * phoneLabel;
@property (nonatomic, strong)ContactBtn * shareButton;
@end


