//
//  ViewController.m
//  XDHttpsTest
//
//  Created by mxd_iOS on 17/2/14.
//  Copyright © 2017年 Xudong.ma. All rights reserved.
//

#import "ViewController.h"

#import "RequestAPIClient.h"

static NSString *const navigationTtemTitle = @"HTTPS网络请求测试";

#define kCurrentBgColor [UIColor colorWithRed:204.f green:204.f blue:204.f alpha:1.0f]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = kCurrentBgColor;
    self.navigationItem.title = navigationTtemTitle;
    
    /** 开始做HTTPS网络请求 (HTTP + SSL证书)
     
        需要单独购买SSL加密证书, 此测试项目仅提供代码预览, 暂不公开证书
     
     **/
    [self HttpsNetworkHandler];
}

- (void)HttpsNetworkHandler
{
    
    /** 主要看内部实现 (此为封装网络请求方法), 参数请自行填写调试*/
    [[RequestAPIClient APIClientInstance] sendRequestPath:@""
                                                   params:@{}
                                                   method:@"post"
                                                  success:^(id responseObject)
    {
        
    } failure:^(NSError *error) {
        
        
    } error:^{
        
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
