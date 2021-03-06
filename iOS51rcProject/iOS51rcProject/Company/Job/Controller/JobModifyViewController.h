//
//  JobModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/9.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@interface JobModifyViewController : WKViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSString *jobId;
@property (strong, nonatomic) IBOutlet UIView *viewTemplate;// 从模板中复制
@property (nonatomic , strong) NSString *templateStr;// 模板名称
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintsJobTypeTop;
@property (strong, nonatomic) IBOutlet UITextField *txtJobName;
@property (strong, nonatomic) IBOutlet UITextField *txtTemplate;
@property (strong, nonatomic) IBOutlet UITextField *txtJobType;
@property (strong, nonatomic) IBOutlet UITextField *txtJobTypeMinor;
@property (strong, nonatomic) IBOutlet UITextField *txtNeedNumber;
@property (strong, nonatomic) IBOutlet UITextField *txtEmployType;
@property (strong, nonatomic) IBOutlet UITextField *txtRegion;
@property (strong, nonatomic) IBOutlet UITextField *txtIssueEnd;
@property (strong, nonatomic) IBOutlet UITextField *txtDegree;
@property (strong, nonatomic) IBOutlet UITextField *txtWorkYears;
@property (strong, nonatomic) IBOutlet UITextField *txtAge;
@property (strong, nonatomic) IBOutlet UITextField *txtResponsibility;
@property (strong, nonatomic) IBOutlet UITextField *txtDemand;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *salaryContraint;// 税前月薪的约束
@property (strong, nonatomic) IBOutlet UIView *salaryView;
@property (strong, nonatomic) IBOutlet UITextField *txtSalary;// 税前月薪范围
@property (strong, nonatomic) IBOutlet UITextField *txtNegotiable;
@property (strong, nonatomic) IBOutlet UITextField *txtWelfare;// 福利待遇
@property (strong, nonatomic) IBOutlet UITextField *txtTags;
@property (strong, nonatomic) IBOutlet UITextField *txtPush;
@end
