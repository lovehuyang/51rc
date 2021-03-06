//
//  ConfirmOrderController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//  确认订单页面

#import "ConfirmOrderController.h"
#import "CVTopPackageModel.h"
#import "CVListModel.h"// 简历模型
#import "DiscountInfoModle.h"
#import "ConfirmOrderCell.h"
#import "DiscountCell.h"
#import "PayWayCell.h"
#import "PayWayModel.h"
#import "WXApi.h"
#import "BottomPayView.h"
#import "Common.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AlertView.h"
#import "BuyTopServiceSuccessAlert.h"
#import "MyOrderViewController.h"


@interface ConfirmOrderController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger payMethodID;// 支付方式1微信，2支付宝（默认）
}
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *cvDataArr;//简历的数据源
@property (nonatomic , strong) NSMutableArray *discountInfoArr;// 代金券数据源
@property (nonatomic , strong) NSMutableArray *payWayArr;//支付方式数据源
@property (nonatomic , strong) BottomPayView *bottomPayView;//底部支付按钮

@end

@implementation ConfirmOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    payMethodID = 2;//
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"确认订单";
    [self.view addSubview:self.tableView];
    [self createUI];
    [self getConfirmOrder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayFailed) name:NOTIFICATION_ALIPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(InquireWeiXinOrder:) name:NOTIFICATION_ALIPAYSUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayFailed) name:NOTIFICATION_WXPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(InquireWeiXinOrder:) name:NOTIFICATION_WXPAYSUCCESS object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ALIPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ALIPAYSUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_WXPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_WXPAYSUCCESS object:nil];
}

- (void)dealloc{
   
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)createUI{
    UILabel *titleLab = [UILabel new];
    [self.view addSubview:titleLab];
    titleLab.sd_layout
    .leftSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(44);
    titleLab.font = DEFAULTFONT;
    titleLab.text = [NSString stringWithFormat:@"    套餐:%@",self.model.orderName];
    UILabel *priceLab = [UILabel new];
    [titleLab addSubview:priceLab];
    priceLab.sd_layout
    .rightSpaceToView(titleLab, 10)
    .topSpaceToView(titleLab, 0)
    .bottomSpaceToView(titleLab, 0);
    priceLab.textColor = NAVBARCOLOR;
    priceLab.textAlignment = NSTextAlignmentRight;
    priceLab.text = [NSString stringWithFormat:@"￥%@",self.model.nowPrice];
    priceLab.font = DEFAULTFONT;
}
- (void)createBottomView{

    if (!_bottomPayView) {
        BottomPayView *bottomPayView = [BottomPayView new];
        [self.view addSubview:bottomPayView];
        bottomPayView.sd_layout
        .leftSpaceToView(self.view, 0)
        .rightSpaceToView(self.view, 0)
        .bottomSpaceToView(self.view, 0)
        .heightIs(45);
        self.bottomPayView = bottomPayView;
    }
    self.bottomPayView.money = [NSString stringWithFormat:@"%.2f",[self payTotalMoney]];
    __weak typeof(self)weakself = self;
    self.bottomPayView.payEvent = ^{
        // 检测时候否安装了微信客户端
        BOOL install = [WXApi isWXAppInstalled];
        
        if (!install && payMethodID == 1) {
            [RCToast showMessage:@"您未安装微信客户端"];
            return ;
        }
        
        [weakself getAppPayOrder];
    };
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - 44 - 45 - 10) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = SEPARATECOLOR;
        _tableView.tableFooterView = [UIView new];
//        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (NSMutableArray *)cvDataArr{
    if (!_cvDataArr) {
        _cvDataArr = [NSMutableArray array];
    }
    return _cvDataArr;
}
- (NSMutableArray *)discountInfoArr{
    if (!_discountInfoArr) {
        _discountInfoArr = [NSMutableArray array];
    }
    return _discountInfoArr;
}

- (NSMutableArray *)payWayArr{
    if (!_payWayArr) {
        _payWayArr = [NSMutableArray array];
        NSMutableArray *payWayArr = [NSMutableArray arrayWithObjects:@"支付宝支付",@"微信支付",nil];
        NSMutableArray *logoNameArr = [NSMutableArray arrayWithObjects:@"icon_alipay",@"icon_wechat_pay",nil];
        
        for (int i = 0; i<payWayArr.count; i ++) {
            PayWayModel *model = [[PayWayModel alloc]init];
            model.payWay = payWayArr[i];
            model.logoName = logoNameArr[i];
            if (i == 0) {
                model.isSelected = YES;
            }else{
                model.isSelected = NO;
            }
            [_payWayArr addObject:model];
        }
    }
    return _payWayArr;
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self)weakself = self;
    if (indexPath.section == 0) {
        ConfirmOrderCell *cell = [[ConfirmOrderCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil indexPath:indexPath dataArr:self.cvDataArr];
        if(indexPath.row > 0){
            cell.cvModel = self.cvDataArr[indexPath.row - 1];
        }
        cell.selectCvBlock = ^(CVListModel *cvModel) {
            for (CVListModel *model in weakself.cvDataArr) {
                if ([model.ID isEqualToString:cvModel.ID]) {
                    model.isSlected = YES;
                }else{
                    model.isSlected = NO;
                }
            }
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if(indexPath.section == 1 && self.discountInfoArr.count){// 代金券
        DiscountCell *cell = [[DiscountCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        if (indexPath.row > 0) {
            cell.discountModel = self.discountInfoArr[indexPath.row - 1];
        }
        cell.selectDiscountBlock = ^(DiscountInfoModle *discountModel) {
            for (DiscountInfoModle *modle in self.discountInfoArr) {
                if ([modle.ID isEqualToString:discountModel.ID]) {
                    modle.isSelceted = YES;
                }else{
                    modle.isSelceted = NO;
                }
            }
            weakself.bottomPayView.money = [NSString stringWithFormat:@"%.2f",[self payTotalMoney]];
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.section == 2 && self.discountInfoArr.count){
        PayWayCell *cell = [[PayWayCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        if (indexPath.row > 0) {
            cell.payModel = self.payWayArr[indexPath.row - 1];
        }
        cell.selectPayWay = ^(PayWayModel *payModel) {
            if([payModel.payWay containsString:@"微信"]){
                payMethodID = 1;
            }else if([payModel.payWay containsString:@"支付宝"]){
                payMethodID = 2;
            }
            
            for (PayWayModel *modle in self.payWayArr) {
                if ([modle.payWay isEqualToString:payModel.payWay]) {
                    modle.isSelected = YES;
                }else{
                    modle.isSelected = NO;
                }
            }
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if (indexPath.section == 1 && self.discountInfoArr.count == 0){
        PayWayCell *cell = [[PayWayCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        if (indexPath.row > 0) {
            cell.payModel = self.payWayArr[indexPath.row - 1];
        }
        cell.selectPayWay = ^(PayWayModel *payModel) {
            if([payModel.payWay containsString:@"微信"]){
                payMethodID = 1;
            }else if([payModel.payWay containsString:@"支付宝"]){
                payMethodID = 2;
            }
            for (PayWayModel *modle in self.payWayArr) {
                if ([modle.payWay isEqualToString:payModel.payWay]) {
                    modle.isSelected = YES;
                }else{
                    modle.isSelected = NO;
                }
            }
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.discountInfoArr.count > 0) {
        return 3;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.discountInfoArr.count > 0) {
        if (section == 0) {
            return self.cvDataArr.count + 1;
        }else if (section == 1){
            return self.discountInfoArr.count + 1;
        }else{
            return self.payWayArr.count + 1;
        }
    }else{
        if (section == 0) {
            return self.cvDataArr.count + 1;
        }else{
            return self.payWayArr.count + 1;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    headerView.backgroundColor = SEPARATECOLOR;
    return headerView;
}

#pragma mark - 支付金额
- (CGFloat)payTotalMoney{
    // 计算优惠的金额
    CGFloat totalDiscountMoney = 0;
    for (DiscountInfoModle *model in self.discountInfoArr) {
        if(model.isSelceted == YES){
            CGFloat discountMoney = [model.Money floatValue];
            totalDiscountMoney =+discountMoney;
            break;
        }
    }
    // 计算应付的金额
    CGFloat totalMoney = [self.model.nowPrice floatValue] - totalDiscountMoney;
    return totalMoney;
}

#pragma mark - 获取订单数据
- (void)getConfirmOrder{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"orderService":self.model.orderService
                                };
    [AFNManager requestPaWithParamDict:paramDict url:URL_GETCONFIRMORDER tableNames:@[@"CvMainInfo",@"DiscountInfo"] successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        
        // 简历数据
        NSArray *cvArr = [requestData firstObject];
        [self dealwithCvData:cvArr];
        
        // 代金券数据
        if (requestData.count>1) {
            NSArray *discountArr = [requestData objectAtIndex:1];
            [self dealwithDiscount:discountArr];
        }

        [self createBottomView];
        [self.tableView reloadData];
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}

#pragma mark - 处理简历数据源
- (void)dealwithCvData:(NSArray *)cvArr{
    
    for (NSDictionary *dict in cvArr) {
        CVListModel *model = [CVListModel buildModelWithDic:dict];
        [self.cvDataArr addObject:model];
    }
    
    for (CVListModel *model in self.cvDataArr) {
        
        if([model.ID isEqualToString:self.cvMainId] && [model.perfectType boolValue]){
            model.isSlected = YES;
            break;
        }
    }
    //  查看有没有选中的完整的简历
    BOOL isSelected = NO;
    for (CVListModel *model in self.cvDataArr) {
        isSelected = isSelected || model.isSlected;
    }
    // 没有选中的，则第一个完整简历为选中状态
    if (isSelected == NO) {
        for (CVListModel *model in self.cvDataArr) {
            if( [model.perfectType boolValue]){
                model.isSlected = YES;
                break;
            }
        }
    }
}

#pragma mark - 处理代金券数据
- (void)dealwithDiscount:(NSArray *)discountArr{
    for (NSDictionary *dict in discountArr) {
        DiscountInfoModle *model = [DiscountInfoModle buildModelWithDic:dict];
        [self.discountInfoArr addObject:model];
    }
    
    for (DiscountInfoModle *model in self.discountInfoArr) {
        model.isSelceted = YES;
        break;
    }
}

#pragma mark - 统一下单接口
- (void)getAppPayOrder{
    [SVProgressHUD show];
    
    // 代金券id
    NSString *discountId = @"";
    if (self.discountInfoArr.count > 0) {
        for (DiscountInfoModle *model in self.discountInfoArr) {
            if (model.isSelceted == YES) {
                discountId = model.ID;
                break;
            }
        }
    }
    
    // ip地址
    NSString *ipStr = [Common getIPaddress];
    
    // 置顶简历的id
    NSString *cvIdStr = @"";
    for (CVListModel *model in self.cvDataArr) {
        if (model.isSlected) {
            cvIdStr = model.ID;
            break;
        }
    }
    
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"cvmainId":cvIdStr,
                                @"orderid":@"",
                                @"orderType":self.orderType,
                                @"payMoney":[NSString stringWithFormat:@"%f",[self payTotalMoney]],
                                @"discountID":discountId,// 代金券id
                                @"payMethodID":[NSString stringWithFormat:@"%ld",(long)payMethodID],
                                @"mobileIP":payMethodID == 2? @"":ipStr,
                                @"payFrom":@"4"
                                };
    
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETAPPPAYORDER tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        if (payMethodID == 1) {
            [self wxpayParamData:(NSString *)dataDict];
        }else if (payMethodID == 2){
            [self alipayParamData:(NSString *)dataDict];
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

- (void)wxpayParamData:(NSString *)dataStr{
    NSDictionary *dataDict = [CommonTools translateJsonStrToDictionary:dataStr];
    
    //需要创建这个支付对象
    PayReq *req   = [[PayReq alloc] init];
    //由用户微信号和AppID组成的唯一标识，用于校验微信用户
    req.openID = [dataDict objectForKey:@"appid"];
    
    // 商家id，在注册的时候给的
    req.partnerId =  [dataDict objectForKey:@"partnerid"];
    
    // 预支付订单这个是后台跟微信服务器交互后，微信服务器传给你们服务器的，你们服务器再传给你
    req.prepayId  =  [dataDict objectForKey:@"prepayid"];
    
    [[NSUserDefaults standardUserDefaults]setObject:dataDict[@"outTradeNo"] forKey:KEY_PAYORDERNUM];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // 根据财付通文档填写的数据和签名
    //这个比较特殊，是固定的，只能是即req.package = Sign=WXPay
    req.package   =  [dataDict objectForKey:@"package"];
    
    // 随机编码，为了防止重复的，在后台生成
    req.nonceStr  =  [dataDict objectForKey:@"noncestr"];
    
    // 这个是时间戳，也是在后台生成的，为了验证支付的
    NSString * stamp =  [dataDict objectForKey:@"timestamp"];
    req.timeStamp = stamp.intValue;
    
    // 这个签名也是后台做的
    req.sign =  [dataDict objectForKey:@"sign"];
    
    //发送请求到微信，等待微信返回onResp
    [WXApi sendReq:req];
}

- (void)alipayParamData:(NSString *)dataStr{
    // 获取appScheme
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSArray * arr = plistDic[@"CFBundleURLTypes"];
    NSString * appScheme = [[[arr objectAtIndex:1] objectForKey:@"CFBundleURLSchemes"] firstObject];
    
    [[AlipaySDK defaultService]payOrder:dataStr fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        if ([resultDic[@"resultStatus"] isEqualToString:@"9000"]){
            
            // 查询支付结果
            NSString *result = resultDic[@"result"];
            NSDictionary *resultDict = [CommonTools translateJsonStrToDictionary:result];
            NSString *out_trade_no = [resultDict[@"alipay_trade_app_pay_response"] objectForKey:@"out_trade_no"];
            [self InquireWeiXinOrder:out_trade_no];
            
        }else{
            [self alipayFailed];
        }
    }];
}

#pragma mark - 支付宝支付通知

- (void)alipayFailed{
   
    self.sendbackOrderName(NO, nil);
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)alipaySuccess{

    self.sendbackOrderName(YES,self.model.orderName);
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 微信支付通知

- (void)wxpayFailed{
    
    self.sendbackOrderName(NO, nil);
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)wxpaySuccess{
    
    self.sendbackOrderName(YES,self.model.orderName);
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 支付宝/微信查询支付结果
- (void)InquireWeiXinOrder:(NSString *)orderNum{
    if (![orderNum isKindOfClass:[NSString class]]) {
        orderNum = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_PAYORDERNUM];
    }
    
    NSDictionary *paramDict = @{
                                @"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"orderNum":orderNum
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_INQUIREWEIXINORDER tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        DLog(@"");
        NSString *result = (NSString *)dataDict;
        if (result != nil && [result isEqualToString:@"1"]) {
            if (payMethodID == 2) {
                [self alipaySuccess];
            }else if (payMethodID == 1){
                [self wxpaySuccess];
            }
        }else{
            if (payMethodID == 2) {
                [self alipayFailed];
            }else if (payMethodID == 1){
                [self wxpayFailed];
            }
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
        
    }];
}
@end
