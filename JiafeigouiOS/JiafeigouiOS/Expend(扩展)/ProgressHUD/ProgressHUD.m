//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProgressHUD.h"
#import "PopAnimation.h"
#import "CommonMethod.h"
#import "JfgLanguage.h"

//加载视图显示时间
#define LOADTIMEOUT 30

@implementation ProgressHUD
//spinner
@synthesize interaction, window, background, hud, image, label;

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (ProgressHUD *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once = 0;
	static ProgressHUD *progressHUD;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ progressHUD = [[ProgressHUD alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return progressHUD;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)dismiss
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[self shared] hudHide];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showProgress:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self shared].interaction = YES;
    [[self shared] hudMake:status havePic:YES iCon:HUD_IMAGE_PROGRESS iconAnimated:YES timedHide:NO];
    [[self shared] performSelector:@selector(progressOuttime) withObject:nil afterDelay:LOADTIMEOUT];
}

+ (void)showProgress:(NSString *)status lastingTime:(CGFloat)lastingTime
{
    [self shared].interaction = YES;
    [[self shared] hudMake:status havePic:YES iCon:HUD_IMAGE_PROGRESS iconAnimated:YES timedHide:NO];
    [[self shared] performSelector:@selector(progressOuttime) withObject:nil afterDelay:lastingTime];
}

+ (void)showProgress:(NSString *)status isTip:(BOOL)isTip lastingTime:(CGFloat)lastingTime
{
    if (isTip)
    {
        [self showProgress:status lastingTime:lastingTime];
    }
    else
    {
        [self shared].interaction = YES;
        [[self shared] hudMake:status havePic:YES iCon:HUD_IMAGE_PROGRESS iconAnimated:YES timedHide:NO];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showProgress:(NSString *)status Interaction:(BOOL)Interaction
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self shared].interaction = Interaction;
    [[self shared] hudMake:status havePic:YES iCon:HUD_IMAGE_PROGRESS iconAnimated:YES timedHide:NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showText:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self shared].interaction = YES;
    [[self shared] hudMake:status havePic:NO iCon:nil iconAnimated:NO timedHide:YES];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showText:(NSString *)status Interaction:(BOOL)Interaction
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status havePic:NO iCon:nil iconAnimated:NO timedHide:YES];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showSuccess:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self shared].interaction = YES;
    [[self shared] hudMake:status havePic:YES iCon:HUD_IMAGE_SUCCESS iconAnimated:NO timedHide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showSuccess:(NSString *)status Interaction:(BOOL)Interaction
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self shared].interaction = Interaction;
	[[self shared] hudMake:status havePic:YES iCon:HUD_IMAGE_SUCCESS iconAnimated:NO timedHide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showWarning:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //[[self shared] hudHide];
	[self shared].interaction = YES;
    [[self shared] hudMake:status havePic:YES iCon:HUD_IMAGE_WARN iconAnimated:NO timedHide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showWarning:(NSString *)status Interaction:(BOOL)Interaction
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self shared].interaction = Interaction;
	[[self shared] hudMake:status havePic:YES iCon:HUD_IMAGE_WARN iconAnimated:NO timedHide:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([delegate respondsToSelector:@selector(window)])
		window = [delegate performSelector:@selector(window)];
	else window = [[UIApplication sharedApplication] keyWindow];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	background = nil; hud = nil; image = nil; label = nil;
//    spinner = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.alpha = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudMake:(NSString *)status havePic:(BOOL)havePic iCon:(UIImage *)ico iconAnimated:(BOOL)spin timedHide:(BOOL)hide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self hudCreateImg:havePic];
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	label.text = status;
	label.hidden = (status == nil) ? YES : NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	image.image = ico;
	image.hidden = (ico == nil) ? YES : NO;
    if (image.isHidden) {
        [image removeFromSuperview];
        image = nil;
    }
	//---------------------------------------------------------------------------------------------------------------------------------------------
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressOuttime) object:nil];
    
	if (spin) [self startLodingAnimation]; else [self stopLoadingAnimation];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self hudSize];
	[self hudPosition:nil];
	[self hudShow];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (hide) [NSThread detachNewThreadSelector:@selector(timedHide) toTarget:self withObject:nil];
    
}
-(void)startLodingAnimation
{
//    if (spinner.superview == nil) [hud addSubview:spinner];
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 20;
    //开始角度
    baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(180);
    //是否永远循环执行
    baseAnimation.repeatForever = YES;
    //添加动画
    [image.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)progressOuttime
{
    [self hudDestroy];
    self.alpha = 0;
    
    if (self.timeOutTip != nil)
    {
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:self.timeOutTip]];//Clear_Sdcard_tips5
    }
    else
    {
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
    }
}

-(void)stopLoadingAnimation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressOuttime) object:nil];
    [image.layer pop_removeAnimationForKey:@"rotation"];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudCreateImg:(BOOL)img
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (hud == nil)
	{
		hud = [[UIToolbar alloc] initWithFrame:CGRectZero];
		hud.translucent = NO;
        hud.tintColor = HUD_BACKGROUND_COLOR;
        hud.barTintColor = HUD_BACKGROUND_COLOR;
		hud.backgroundColor = HUD_BACKGROUND_COLOR;

		hud.layer.cornerRadius = 10;
		hud.layer.masksToBounds = YES;
		[self registerNotifications];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (hud.superview == nil)
	{
		if (interaction == NO)
		{
			background = [[UIView alloc] initWithFrame:window.frame];
			background.backgroundColor = HUD_WINDOW_COLOR;
			[window addSubview:background];
			[background addSubview:hud];
		}
		else [window addSubview:hud];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
    if (img) {
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//        if (spinner == nil)
//        {
//            spinner = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ProgressHUD.bundle/loading.png"]];
//            
//        }
        //---------------------------------------------------------------------------------------------------------------------------------------------
        if (image == nil)
        {
            image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        }
        if (image.superview == nil) [hud addSubview:image];
    }
	
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (label == nil)
	{
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.font = HUD_STATUS_FONT;
		label.textColor = HUD_STATUS_COLOR;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.numberOfLines = 0;
	}
	if (label.superview == nil) [hud addSubview:label];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)registerNotifications
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:)
												 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardDidShowNotification object:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudDestroy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[label removeFromSuperview];		label = nil;
    if (image != nil) {
        [image removeFromSuperview];	image = nil;
    }
//    if (spinner != nil) {
//        [spinner removeFromSuperview];	spinner = nil;
//    }
	[hud removeFromSuperview];			hud = nil;
	[background removeFromSuperview];	background = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressOuttime) object:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudSize
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect labelRect = CGRectZero;
	CGFloat hudWidth = 90, hudHeight = 80;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (label.text != nil)
	{
		NSDictionary *attributes = @{NSFontAttributeName:label.font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		labelRect = [label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];

		labelRect.origin.x = 20;
		labelRect.origin.y = (image == nil? 15 : 50);

		hudWidth = labelRect.size.width + 40;
        hudHeight = labelRect.size.height + (image == nil? 30 : 65);

		if (hudWidth < 90)
		{
			hudWidth = 90;
			labelRect.origin.x = 0;
			labelRect.size.width = 90;
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	hud.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat imagex = hudWidth/2;
	CGFloat imagey = (label.text == nil) ? hudHeight/2 : 27.5;
	image.center = CGPointMake(imagex, imagey);
//    = spinner.center 
	//---------------------------------------------------------------------------------------------------------------------------------------------
	label.frame = labelRect;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudPosition:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGFloat heightKeyboard = 0;
	NSTimeInterval duration = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (notification != nil)
	{
		NSDictionary *info = [notification userInfo];
		CGRect keyboard = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		if ((notification.name == UIKeyboardWillShowNotification) || (notification.name == UIKeyboardDidShowNotification))
		{
			heightKeyboard = keyboard.size.height;
		}
	}
	else heightKeyboard = [self keyboardHeight];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect screen = [UIScreen mainScreen].bounds;
	CGPoint center = CGPointMake(screen.size.width/2, (screen.size.height-heightKeyboard)/2);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		hud.center = CGPointMake(center.x, center.y);
	} completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (background != nil) background.frame = window.frame;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)keyboardHeight
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (UIWindow *testWindow in [[UIApplication sharedApplication] windows])
	{
		if ([[testWindow class] isEqual:[UIWindow class]] == NO)
		{
			for (UIView *possibleKeyboard in [testWindow subviews])
			{
				if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"])
				{
					return possibleKeyboard.bounds.size.height;
				}
				else if ([[possibleKeyboard description] hasPrefix:@"<UIInputSetContainerView"])
				{
					for (UIView *hostKeyboard in [possibleKeyboard subviews])
					{
						if ([[hostKeyboard description] hasPrefix:@"<UIInputSetHost"])
						{
							return hostKeyboard.frame.size.height;
						}
					}
				}
			}
		}
	}
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudShow
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (self.alpha == 0)
	{
		self.alpha = 0.7;

		hud.alpha = 0;
		hud.transform = CGAffineTransformScale(hud.transform, 1.4, 1.4);

		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			hud.transform = CGAffineTransformScale(hud.transform, 1/1.4, 1/1.4);
			hud.alpha = 0.7;
        } completion:^(BOOL finished) {
           
        }];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudHide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self.timeOutTip = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressOuttime) object:nil];
	if (self.alpha != 0)
	{
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			hud.transform = CGAffineTransformScale(hud.transform, 0.7, 0.7);
			hud.alpha = 0;
		}
		completion:^(BOOL finished) {
			[self hudDestroy];
			self.alpha = 0;
		}];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)timedHide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	@autoreleasepool
	{
		double length = label.text.length;
		NSTimeInterval sleep = length * 0.04 + 0.5;
        if (sleep <1) {
            sleep = 1 ;
        }
		[NSThread sleepForTimeInterval:sleep];

		dispatch_async(dispatch_get_main_queue(), ^{
			[self hudHide];
		});
	}
}

@end
