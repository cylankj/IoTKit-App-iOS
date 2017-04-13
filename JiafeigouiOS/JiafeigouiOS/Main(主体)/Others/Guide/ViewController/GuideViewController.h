//
//  GuideViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/5/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideViewController : UIViewController<UIScrollViewDelegate>
{
    UIScrollView * guideScrollView;
    
    UIPageControl * pageController;
}
@end
