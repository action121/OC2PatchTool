//
//  MBChangeLogViewController.m
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/14.
//

#import "MBChangeLogViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry.h>

@interface MBChangeLogViewController ()<WKNavigationDelegate>

@property (strong)  WKWebView *changeLogWebView;

@end

@implementation MBChangeLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setUP];
    
}

-(void)viewDidAppear{
    [super viewDidAppear];
    self.view.window.titleVisibility = NSWindowTitleVisible;
    self.view.window.title = @"Change Log";
}
-(void)setUP{
    [self loadChangeLog];
}

-(void)loadChangeLog{
    
    if (!_changeLogWebView) {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        webView.navigationDelegate = self;
        [self.view addSubview:webView];
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(24);
            make.bottom.mas_equalTo(0);
        }];
        _changeLogWebView = webView;
    }
    NSString *qaBundlePath = [[NSBundle mainBundle] pathForResource:@"QA" ofType:nil];
    NSString *logFilePath = [NSString stringWithFormat:@"%@/changeLog/changeLog.txt",qaBundlePath];
    NSString *logContent = [[NSString alloc] initWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
    logContent = [logContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    logContent = [logContent stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;&nbsp;&nbsp;&nbsp;"];
    [self.changeLogWebView loadHTMLString:logContent baseURL:[NSURL fileURLWithPath:qaBundlePath]];
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@ \n MIMEType :%@",navigationResponse.response.URL.absoluteString,navigationResponse.response.MIMEType);
    if ([navigationResponse.response.URL isFileURL]) {
         decisionHandler(WKNavigationResponsePolicyAllow);
        return;
    }

    if ([[NSThread currentThread] isMainThread]) {
        [[NSWorkspace sharedWorkspace] openURL:navigationResponse.response.URL];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSWorkspace sharedWorkspace] openURL:navigationResponse.response.URL];
        });
    }
    //不允许跳转
    decisionHandler(WKNavigationResponsePolicyCancel);
    
}

@end
