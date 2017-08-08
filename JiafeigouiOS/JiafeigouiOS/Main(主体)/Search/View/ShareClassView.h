//
//  ShareClassView.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    shareTypeVendor,//default
    shareTypeDevice,
}shareClassType;

@interface ShareClassView : UIView

@property (nonatomic,strong)id obj;
//@property (nonatomic, assign)shareType type;

-(instancetype)initWithFrame:(CGRect)frame shareWithContent:(NSMutableDictionary *)content withType:(shareClassType)type navigationController:(UINavigationController *)nav Cid:(NSString *)cid;

+(ShareClassView *)showShareViewWitnContent:(NSMutableDictionary *)dictionary withType:(shareClassType)type navigationController:(UINavigationController *)nav Cid:(NSString *)cid;

+(void)showShareViewWithTitle:(NSString *)title content:(NSString *)content url:(NSString *)url image:(UIImage *)image imageUrl:(NSString *)imageUrl Type:(shareClassType)type navigationController:(UINavigationController *)nav Cid:(NSString *)cid;
-(void)dismiss;

@end

@interface ShareCoverView : UIView

@end
