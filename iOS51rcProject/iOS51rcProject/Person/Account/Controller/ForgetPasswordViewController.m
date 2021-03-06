//
//  ForgetPasswordViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/5.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "CommonMacro.h"
@import WebKit;

@interface ForgetPasswordViewController ()<WKNavigationDelegate, WKScriptMessageHandler>

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"取回密码";
    WKWebViewConfiguration *config =
    [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"dismissView"];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) configuration:config];
    [webView setNavigationDelegate:self];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/personal/sys/getpassword", [USER_DEFAULT valueForKey:@"subsite"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('header').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
    if ([[[webView.URL absoluteString] lowercaseString] rangeOfString:@"success"].location != NSNotFound) {
        [webView evaluateJavaScript:@"$('.ConfirmButton').attr('onclick', '').click(function(){window.webkit.messageHandlers.dismissView.postMessage('')})" completionHandler:nil];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
