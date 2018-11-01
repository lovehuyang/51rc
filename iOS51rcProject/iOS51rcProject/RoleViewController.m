//
//  RoleViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/1.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "RoleViewController.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "UIView+Toast.h"

@interface RoleViewController ()

@property (nonatomic, strong) UIButton *btnPa;
@property (nonatomic, strong) UIButton *btnCp;
@property int activeStatus;
@end

@implementation RoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activeStatus = 0;
    UIImageView *imageBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageBackground setImage:[UIImage imageNamed:@"img_rolebg.png"]];
    [imageBackground setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:imageBackground];
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT * 0.25, SCREEN_WIDTH, 30)];
    [lbTitle setText:@"请选择您的身份"];
    [lbTitle setTextColor:UIColorWithRGBA(112, 25, 19, 1)];
    [lbTitle setFont:FONT(22)];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lbTitle];
    
    self.btnPa = [self roleButton:YES active:!self.isCompany];
    self.btnCp = [self roleButton:NO active:self.isCompany];
    [self.view addSubview:self.btnPa];
    [self.view addSubview:self.btnCp];
    
    UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT * 0.7, SCREEN_WIDTH - 40, 50)];
    [btnConfirm setBackgroundColor:NAVBARCOLOR];
    [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
    [btnConfirm addTarget:self action:@selector(confirmClick) forControlEvents:UIControlEventTouchUpInside];
    [btnConfirm.layer setCornerRadius:25];
    [self.view addSubview:btnConfirm];
}

- (UIButton *) roleButton:(BOOL)pa active:(BOOL)active {
    if (pa && active) {
        self.activeStatus = 1;
    }
    else if (!pa && active) {
        self.activeStatus = 2;
    }
    float fltBtnY = SCREEN_HEIGHT * 0.25 + 70;
    if (!pa) {
        fltBtnY += 70;
    }
    UIButton *btnRole = [[UIButton alloc] initWithFrame:CGRectMake(20, fltBtnY, SCREEN_WIDTH - 40, 50)];
    [btnRole setBackgroundColor:[UIColor whiteColor]];
    [btnRole setTag:(pa ? 0 : 1)];
    [btnRole.layer setCornerRadius:25];
    [btnRole addTarget:self action:@selector(roleClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgRole = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
    [imgRole setImage:[UIImage imageNamed:(pa ? @"img_rolepa2.png" : @"img_rolecp2.png")]];
    [btnRole addSubview:imgRole];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(imgRole) + 15, 10, 1, 30)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [btnRole addSubview:viewSeparate];
    
    WKLabel *lbRole = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(viewSeparate) + 15, 10, SCREEN_WIDTH, 30) content:(pa ? @"我要求职" : @"我要招聘") size:18 color:[UIColor blackColor]];
    [btnRole addSubview:lbRole];
    
    UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W(btnRole) - 45, 12, 26, 26)];
    [imgCheck setImage:[UIImage imageNamed:@"img_check2.png"]];
    [btnRole addSubview:imgCheck];
    if (active) {
        [btnRole.layer setBorderColor:[NAVBARCOLOR CGColor]];
        [btnRole.layer setBorderWidth:1.0f];
        [imgRole setImage:[UIImage imageNamed:(pa ? @"img_rolepa1.png" : @"img_rolecp1.png")]];
        [viewSeparate setBackgroundColor:NAVBARCOLOR];
        [lbRole setTextColor:NAVBARCOLOR];
        [imgCheck setImage:[UIImage imageNamed:@"img_check1.png"]];
    }
    return btnRole;
}

- (void)roleClick:(UIButton *)button {
    [self.btnPa removeFromSuperview];
    [self.btnCp removeFromSuperview];
    self.btnPa = [self roleButton:YES active:(button.tag == 0)];
    self.btnCp = [self roleButton:NO active:(button.tag == 1)];
    [self.view addSubview:self.btnPa];
    [self.view addSubview:self.btnCp];
}

- (void)confirmClick {
    if ([[USER_DEFAULT valueForKey:@"userType"] isEqualToString:[NSString stringWithFormat:@"%d", self.activeStatus]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (self.activeStatus == 1) {
        [USER_DEFAULT setValue:@"1" forKey:@"userType"];
        if (!PERSONLOGIN) {
            UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
            [self presentViewController:loginCtrl animated:NO completion:nil];
        }
        else {
            UITabBarController *personCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"personView"];
            [self presentViewController:personCtrl animated:NO completion:nil];
        }
    }
    else if (self.activeStatus == 2) {
        [USER_DEFAULT setValue:@"2" forKey:@"userType"];
        if (!COMPANYLOGIN) {
            UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
            [self presentViewController:loginCtrl animated:NO completion:nil];
        }
        else {
            UITabBarController *companyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"companyView"];
            [self presentViewController:companyCtrl animated:NO completion:nil];
        }
    }
    else {
        [self.view makeToast:@"请选择身份"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
