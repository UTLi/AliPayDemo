//
//  ViewController.m
//  支付宝demo
//
//  Created by 李沛 on 15/11/20.
//  Copyright © 2015年 LP. All rights reserved.
//

#import "ViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "MBProgressHUD.h"
@interface ViewController ()<UIAlertViewDelegate>


@property(nonatomic , assign) float Price;//支付金额
@property(nonatomic , retain) NSString *res;//处理返回数据用
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 100, 120, 30);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(Pay) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"支付" forState:UIControlStateNormal];

    // Do any additional setup after loading the view, typically from a nib.
}

#warning 数据都是假的讲解用，若想测试换成真实数据就好
//点击支付按钮
-(void)Pay{
    NSString *partner = @"2088511933544308";//商户ID  不知道还能不能用，用自己公司的就好
    NSString *seller = @"yingtehua8@sina.com";//商户支付宝账号
    if (self.Price == 0.00) {
        //如果是0元,这点是自己加的因为，不管是支付宝银联还是微信支付，都无法支付零元的情况，所以自己解决一下就好了
       UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"支付成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        /*
         *生成订单信息及签名
         */
        //将商品信息赋予AlixPayOrder的成员变量
        
        
   //**********************这一段是在本地生成订单的代码若在服务器生成订单则不需要
        Order *order = [[Order alloc] init];
        order.partner = partner;
        order.seller = seller;
        order.tradeNO = @"1111111111"; //订单ID（由商家自行制定）
        order.productName = @"iphone6s"; //商品标题
        
        order.productDescription = @"iphone6s粉色64G"; //商品描述
        order.amount = @"6666.00"; //商品价格
        order.notifyURL = @"www.baidu.com"; //回调URL,自己公司绝一定
        
        order.service = @"mobile.securitypay.pay";
        order.paymentType = @"1";
        order.inputCharset = @"utf-8";
        order.itBPay = @"30m";
        NSString *orderSpec = [order description];//订单信息
  //****************************  最终得到订单信息orderSpec，可以在服务器生成
        
        
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types 注意这一项是跳到支付宝再跳转回来自己APP的标志
        NSString *appScheme = @"zhifubaoDemo";
        
        //将签名成功字符串格式化为订单字符串,请严格按照该格式 signedString是签名加密后的字符串 ，我们公司为了安全是把私钥放在了服务器，官方demo是放在工程里的，这里就先随便设置一个了
        NSString *signedString = @"signedString";//签名后的字符串
        NSString *orderString = nil;
        if (signedString != nil) {
            orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                           orderSpec, signedString, @"RSA"];

            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                //检测返回数据,注意这里就是支付宝比较坑了，没给处理返回数据，还得自己写一段剪切字符串
                NSString *resultSting = resultDic[@"result"];
                NSArray *resultStringArray =[resultSting componentsSeparatedByString:NSLocalizedString(@"&", nil)];
                for (NSString *str in resultStringArray)
                {
                    NSString *newstring = nil;
                    newstring = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    NSArray *strArray = [newstring componentsSeparatedByString:NSLocalizedString(@"=", nil)];
                    for (int i = 0 ; i < [strArray count] ; i++)
                    {
                        NSString *st = [strArray objectAtIndex:i];
                        if ([st isEqualToString:@"success"])
                        {
                            NSLog(@"%@",[strArray objectAtIndex:1]);
                            _res = [strArray objectAtIndex:1];
                        }
                    }
                }
                //判断返回结果
                if ( [resultDic[@"resultStatus"] isEqual:@"9000"]&&[_res isEqual:@"true"]) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"支付成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }else if( [resultDic[@"resultStatus"] isEqual:@"6001"]){
                    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"您已取消支付" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil , nil];
                    alterView.tag = 102;
                    [alterView show];
                }else if([resultDic[@"resultStatus"] isEqual:@"6002"]){
                    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"网络连接错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil , nil];
                    alterView.tag = 102;
                    [alterView show];
                    
                }else if ([resultDic[@"resultStatus"] isEqual:@"4000"]){
                    
                    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"订单支付失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil , nil];
                    alterView.tag = 102;
                    [alterView show];
                }else if([resultDic[@"resultStatus"] isEqual:@"8000"]){
                    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"正在处理中" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil , nil];
                    alterView.tag = 102;
                    [alterView show];
                }
            }];
        }
    
    }


}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
