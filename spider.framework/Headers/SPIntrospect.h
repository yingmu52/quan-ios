//
//  SPIntrospect.h
//
#define kSPIntrospectNotificationIntrospectionDidStart @"kSPIntrospectNotificationIntrospectionDidStart"
#define kSPIntrospectNotificationIntrospectionDidEnd @"kSPIntrospectNotificationIntrospectionDidEnd"
#define kSPIntrospectAnimationDuration 0.08

#import <objc/runtime.h>

//#ifdef DEBUG
//
//@interface UIView (debug)
//
//- (NSString *)recursiveDescription;
//
//@end
//
//#endif

@interface SPIntrospect : NSObject <UITextViewDelegate, UIWebViewDelegate ,UITableViewDelegate, UITableViewDataSource , UIGestureRecognizerDelegate>
{
}
+ (SPIntrospect *)sharedIntrospector;

-(void)setSpiderId:(NSString *)spiderId;
-(NSString *)spiderId;
-(void)setNeedEncript:(BOOL)needEncript;
-(BOOL)needEncript;
-(void)openSpider;
-(void)setNeedCloseSpiderWhenEnterBackground:(BOOL)needCloseSpiderWhenEnterBackground;
-(void)closeSpider;
-(BOOL)isOpen;

- (void)start;
- (void)startWithPublicKeyPath:(NSString *)path;
- (void)setInvokeGestureRecognizer:(UIGestureRecognizer *)newGestureRecognizer withRect:(CGRect)touchZone;
- (void)setShowViewTreeGestureRecognizer:(UIGestureRecognizer *)newGestureRecognizer;
- (void)setStaticClassArray:(NSArray*)a;
- (void)startPerformentMonitor;
- (void)stopPerformentMonitor;
- (NSDictionary *)getFpsData;
- (NSDictionary *)getTouchEvents;
@end
