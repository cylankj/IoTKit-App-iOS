
#import <UIKit/UIKit.h>


@interface WeiboLiveSDK : NSObject

//http://open.weibo.com/wiki/Live/api


- (NSString *) createLive:(NSString *)access_token
                    title:(NSString*)title
                    width:(NSString*)width
                    height:(NSString*)height
                    summary:(NSString*)summary
                    published:(NSString*)published
                    image:(NSString*)image
                    replay:(NSString*)replay
                    is_panolive:(NSString*)is_panolive;

- (NSString *) updateLive:(NSString *)access_token
                    liveid:(NSString*)liveid
                    title:(NSString*)title
                   summary:(NSString*)summary
                  published:(NSString*)published
                image:(NSString*)image
                    stop:(NSString*)stop
               replay_url:(NSString*)replay_url;

- (NSString *) deleteLive:(NSString *)access_token
                   liveid:(NSString*)liveid;

- (NSString *) showLive:(NSString *)access_token
                 liveid:(NSString*)liveid
                 detail:(NSString*)detail;



@end
