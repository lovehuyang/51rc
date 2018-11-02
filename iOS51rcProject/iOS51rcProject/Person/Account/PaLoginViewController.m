//
//  PaLoginViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/5.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  账号密码登录

#import "PaLoginViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "ForgetPasswordViewController.h"
#import "WKNavigationController.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import "JPUSHService.h"
#import "AgreementViewController.h"
#import "NavBar.h"

@interface PaLoginViewController ()<UITextFieldDelegate, NetWebServiceRequestDelegate>
{
    BOOL isPasswordLogin;// 默认是密码登录
}
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic , strong)UILabel *loginTypeLab;
@end

@implementation PaLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isPasswordLogin = YES;
    // 假导航栏
    NavBar *navView = [[NavBar alloc]initWithTitle:@"" leftItem:@"nav_return"];
    [self.view addSubview:navView];
    
    UIImageView *logoImgView = [UIImageView new];
    [self.view addSubview:logoImgView];
    logoImgView.sd_layout
    .centerXEqualToView(self.view)
    .topSpaceToView(navView, -40)
    .widthIs(100)
    .heightEqualToWidth();
    logoImgView.image = [UIImage imageNamed:@"pa_loginphoto.png"];
    
    UILabel *loginTypeLab = [UILabel new];
    [self.view addSubview:loginTypeLab];
    loginTypeLab.sd_layout
    .topSpaceToView(logoImgView, 5)
    .centerXEqualToView(logoImgView)
    .widthIs(100)
    .heightIs(20);
    loginTypeLab.text = @"密码登录";
    loginTypeLab.textAlignment = NSTextAlignmentCenter;
    loginTypeLab.font = SMALLERFONT;
    self.loginTypeLab = loginTypeLab;
    
    navView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.view, -100)
    .bottomSpaceToView(self.view, SCREEN_HEIGHT - HEIGHT_STATUS_NAV);
    __weak typeof(self)weakSelf = self;
    navView.leftItemEvent = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];;
    };
    
    [Common changeFontSize:self.view];
    [self.navigationController.navigationBar setHidden:YES];
    [self.btnOneMinute setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [self.btnOneMinute.layer setBorderWidth:1];
    [self.btnOneMinute.layer setBorderColor:[NAVBARCOLOR CGColor]];
    [self.btnOneMinute.layer setCornerRadius:VIEW_H(self.btnOneMinute) / 5];
    
    [self.btnRegister setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [self.btnRegister.layer setBorderWidth:1];
    [self.btnRegister.layer setBorderColor:[NAVBARCOLOR CGColor]];
    [self.btnRegister.layer setCornerRadius:VIEW_H(self.btnOneMinute) / 5];
    [self.constraintOneMinuteWidth setConstant:SCREEN_WIDTH * 0.55];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.runningRequest cancel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)loginClick:(id)sender {
    [self.view endEditing:YES];
    if (self.txtUsername.text.length == 0) {
        [self.view makeToast:self.txtUsername.placeholder];
        return;
    }
    if (self.txtPassword.text.length == 0) {
        [self.view makeToast:self.txtPassword.placeholder];
        return;
    }
    if (self.btnAgree.tag == 0) {
        [self.view makeToast:@"请勾选用户协议"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"Login" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.txtUsername.text, @"userName", self.txtPassword.text, @"passWord", [USER_DEFAULT objectForKey:@"provinceId"], @"provinceID", @"ismobile:IOS", @"browser", @"0", @"autoLogin", [JPUSHService registrationID], @"jpushId", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (IBAction)forgetPasswordClick:(id)sender {
    ForgetPasswordViewController *forgetPasswordCtrl = [[ForgetPasswordViewController alloc] init];
    WKNavigationController *forgetPasswordNav = [[WKNavigationController alloc] initWithRootViewController:forgetPasswordCtrl];
    forgetPasswordNav.wantClose = YES;
    [self presentViewController:forgetPasswordNav animated:YES completion:nil];
}

- (IBAction)passwordClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.txtPassword setSecureTextEntry:NO];
        [sender setBackgroundImage:[UIImage imageNamed:@"img_password1.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [self.txtPassword setSecureTextEntry:YES];
        [sender setBackgroundImage:[UIImage imageNamed:@"img_password2.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        if ([result rangeOfString:@"|"].location != NSNotFound) {
            NSArray *arrayResult = [result componentsSeparatedByString:@"|"];
            NSString *paMainId = [arrayResult objectAtIndex:0];
            NSString *regDate = [arrayResult objectAtIndex:1];
            NSString *realCode = [NSString stringWithFormat:@"%@%@%@%@%@",[regDate substringWithRange:NSMakeRange(11,2)],
             [regDate substringWithRange:NSMakeRange(0,4)],[regDate substringWithRange:NSMakeRange(14,2)],
             [regDate substringWithRange:NSMakeRange(8,2)],[regDate substringWithRange:NSMakeRange(5,2)]];
            
            NSString *code = [Common MD5:[NSString stringWithFormat:@"%lld", ([realCode longLongValue] + [paMainId longLongValue])]];
            [USER_DEFAULT setValue:paMainId forKey:@"paMainId"];
            [USER_DEFAULT setValue:code forKey:@"paMainCode"];
            [USER_DEFAULT setValue:[arrayResult objectAtIndex:2] forKey:@"provinceId"];
            [USER_DEFAULT setValue:[arrayResult objectAtIndex:3] forKey:@"province"];
            [USER_DEFAULT setValue:[[arrayResult objectAtIndex:4] stringByReplacingOccurrencesOfString:@"www." withString:@"m."] forKey:@"subsite"];
            [USER_DEFAULT setValue:[arrayResult objectAtIndex:5] forKey:@"subsitename"];
            
            UITabBarController *personCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"personView"];
            [personCtrl setSelectedIndex:4];
            [self presentViewController:personCtrl animated:YES completion:^{
                [USER_DEFAULT setObject:@"1" forKey:@"positioned"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"paLoginSuccess" object:self];
            }];
        }
        else if ([result isEqual:@"-1"]) {
            [self.view makeToast:@"您今天的登录次数已超过20次的限制，请明天再来"];
        }
        else if ([result isEqual:@"-2"]) {
            [self.view makeToast:@"请提交意见反馈向我们反映，谢谢配合"];
        }
        else if ([result isEqual:@"-3"]) {
            [self.view makeToast:@"提交错误，请检查您的网络链接，并稍后重试"];
        }
        else if ([result isEqual:@"0"]) {
            [self.view makeToast:@"用户名或密码错误，请重新输入"];
        }
        else {
            [self.view makeToast:@"您今天的登录次数已超过20次的限制，请明天再来"];
        }
    }
}

- (IBAction)agreeClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [sender setBackgroundImage:[UIImage imageNamed:@"img_checksmall1.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [sender setBackgroundImage:[UIImage imageNamed:@"img_checksmall2.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (IBAction)agreementClick:(UIButton *)sender {
    AgreementViewController *agreementCtrl = [[AgreementViewController alloc] init];
    WKNavigationController *agreementNav = [[WKNavigationController alloc] initWithRootViewController:agreementCtrl];
    agreementNav.wantClose = YES;
    agreementCtrl.title = [NSString stringWithFormat:@"%@个人会员协议", [USER_DEFAULT valueForKey:@"subsitename"]];
    [self presentViewController:agreementNav animated:YES completion:nil];
}

#pragma mark - 切换登录方式

- (IBAction)changeLoginType:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if ([btn.titleLabel.text isEqualToString:@"验证码登录"]) {
        [btn setTitle:@"密码登录" forState:UIControlStateNormal];
        isPasswordLogin = NO;
    }else{
        [btn setTitle:@"验证码登录" forState:UIControlStateNormal];
        isPasswordLogin = YES;
    }
    [self changeUIStatus];
}

#pragma mark - 改变控件的状态

- (void)changeUIStatus{
    if (isPasswordLogin) {
        self.loginTypeLab.text = @"密码登录";
        self.txtUsername.placeholder = @"请输入邮箱或手机号";
        self.txtPassword.placeholder = @"请输入密码";
    }else{
        self.loginTypeLab.text = @"验证码登录";
        self.txtUsername.placeholder = @"请输入已认证手机号";
        self.txtPassword.placeholder = @"短信验证码";
        self.passwordBtn.hidden = YES;
    }
}
@end
