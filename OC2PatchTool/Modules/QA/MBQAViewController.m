//
//  SFQAViewController.m
//  SFIM
//
//  Created by 吴晓明 on 2018/6/25.
//  Copyright © 2018年 . All rights reserved.
//

#import "MBQAViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry.h>

@interface MBQAViewController ()<WKNavigationDelegate>
@property (strong)  WKWebView *qaWebView;
@end

@implementation MBQAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setUP];
    
}

-(void)viewDidAppear{
    [super viewDidAppear];
    self.view.window.titleVisibility = NSWindowTitleVisible;
    self.view.window.title = @"QA";
}
-(void)setUP{
    [self loadQA];
}

-(void)loadQA{
    if (!self.qaWebView) {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        webView.navigationDelegate = self;
        [self.view addSubview:webView];
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(24);
            make.bottom.mas_equalTo(0);
        }];
        self.qaWebView = webView;
    }

    NSString *qaBundlePath = [[NSBundle mainBundle] pathForResource:@"QA" ofType:nil];
    NSString *qaIndexPagePath = [NSString stringWithFormat:@"%@/html/index.html",qaBundlePath];
    NSURL *homeURL = [NSURL fileURLWithPath:qaIndexPagePath];

    [self.qaWebView loadFileURL:homeURL allowingReadAccessToURL:[NSURL fileURLWithPath:qaBundlePath]];

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%s", __FUNCTION__);
    if ([navigationAction.request.URL isFileURL]) {
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        return;
    }
    if ([[NSThread currentThread] isMainThread]) {
        [[NSWorkspace sharedWorkspace] openURL:navigationAction.request.URL];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSWorkspace sharedWorkspace] openURL:navigationAction.request.URL];
        });
    }
    if (decisionHandler) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
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
