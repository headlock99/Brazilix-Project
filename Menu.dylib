#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface FLUMenuController : NSObject <WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *menuContainer;
@end

@implementation FLUMenuController

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[FLUMenuController sharedInstance] initMenu];
    });
}

+ (instancetype)sharedInstance {
    static FLUMenuController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)initMenu {
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    twoFingerTap.numberOfTouchesRequired = 2;
    [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:twoFingerTap];

    self.menuContainer = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.menuContainer.backgroundColor = [UIColor clearColor];
    self.menuContainer.hidden = YES; 
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.menuContainer];

    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"FLUHandler"];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;

    self.webView = [[WKWebView alloc] initWithFrame:self.menuContainer.bounds configuration:configuration];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FLU_Menu" ofType:@"bundle"];
    NSString *htmlPath = [bundlePath stringByAppendingPathComponent:@"index.html"];
    NSURL *fileURL = [NSURL fileURLWithPath:htmlPath];
    
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:[fileURL URLByDeletingLastPathComponent]];
    [self.menuContainer addSubview:self.webView];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"FLUHandler"]) {
        NSDictionary *data = message.body;
        NSString *feature = data[@"feature"];
        id status = data[@"status"];
        NSLog(@"[FLU FF] Thay đổi tính năng: %@ -> Giá trị: %@", feature, status);
    }
}

- (void)handleTwoFingerTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.menuContainer.hidden = !self.menuContainer.hidden;
    }
}
@end
