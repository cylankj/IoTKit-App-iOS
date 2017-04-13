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

#import <UIKit/UIKit.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define HUD_STATUS_FONT			[UIFont systemFontOfSize:15]
#define HUD_STATUS_COLOR		[UIColor whiteColor]

#define HUD_SPINNER_COLOR		[UIColor whiteColor];
#define HUD_BACKGROUND_COLOR	[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
#define HUD_WINDOW_COLOR		[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];

#define HUD_IMAGE_SUCCESS		[UIImage imageNamed:@"ProgressHUD.bundle/progresshud-success.png"]
#define HUD_IMAGE_WARN			[UIImage imageNamed:@"ProgressHUD.bundle/progresshud-warn.png"]
#define HUD_IMAGE_PROGRESS      [UIImage imageNamed:@"ProgressHUD.bundle/loading.png"]

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ProgressHUD : UIView
//-------------------------------------------------------------------------------------------------------------------------------------------------

+ (ProgressHUD *)shared;

+ (void)dismiss;

/**
 *  弹出文字框（默认加到window、转圈动画start、不会自动消失）
 *
 *  @param status 文字
 */
+ (void)showProgress:(NSString *)status;
+ (void)showProgress:(NSString *)status lastingTime:(CGFloat)lastingTime;
+ (void)showProgress:(NSString *)status isTip:(BOOL)isTip lastingTime:(CGFloat)lastingTime;
/**
 *  弹出文字框
 *
 *  @param status      文字
 *  @param Interaction 交互（加载到window/加载到一个不可交互的图层）
 */
+ (void)showProgress:(NSString *)status Interaction:(BOOL)Interaction;
/**
 *  只显示文字提示
 *
 *  @param status 文字
 */
+ (void)showText:(NSString *)status;
/**
 *  只显示文字提示
 *
 *  @param status      文字
 *  @param Interaction 同上
 */
+ (void)showText:(NSString *)status Interaction:(BOOL)Interaction;
/**
 *  弹出成功提示，图片为√
 *
 *  @param status 文字
 */
+ (void)showSuccess:(NSString *)status;
/**
 *  弹出成功提示，图片为√
 *
 *  @param status      文字
 *  @param Interaction 同上
 */
+ (void)showSuccess:(NSString *)status Interaction:(BOOL)Interaction;
/**
 *  弹出警告提示
 *
 *  @param status 文字
 */
+ (void)showWarning:(NSString *)status;
/**
 *  弹出警告提示
 *
 *  @param status      文字
 *  @param Interaction 同上
 */
+ (void)showWarning:(NSString *)status Interaction:(BOOL)Interaction;

@property (nonatomic, assign) BOOL interaction;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIView *background;
@property (nonatomic, retain) UIToolbar *hud;
@property (nonatomic, retain) UIImageView *spinner;
@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UILabel *label;

@property (nonatomic, copy) NSString *timeOutTip;
@end
