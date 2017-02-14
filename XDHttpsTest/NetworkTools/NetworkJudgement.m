//
//  NetworkJudgement.m
//  iWater
//
//  Created by Xudong.ma on 16/5/11.
//  Copyright © 2016年 Xudong.ma. All rights reserved.
//

#import "NetworkJudgement.h"
#import "AFNetworking.h"

@implementation NetworkJudgement

+ (__kindof NetworkJudgement *)defaultInstance
{
    static NetworkJudgement *networkJudgement = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        networkJudgement = [[NetworkJudgement alloc] init];
    });
    
    return networkJudgement;
}

- (void)judgeNetWorkIsAvailable
{
    /**
     *  获得网络监控的管理者
     */
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /**
     *  设置网络状态改变后的处理 (当网络状态发生变化会自动调用下面block)
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
                
            case AFNetworkReachabilityStatusUnknown:
                
//                postNotificationWhenNetworkingConnectFailed();
//                XDLog(@"未知网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                
//                postNotificationWhenNetworkingConnectFailed();
//                XDLog(@"没有网络(断网)");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
//                XDLog(@"wifi");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
//                XDLog(@"手机自带网络");
                break;
        }
    }];
    
    /**
     *  开始监听
     */
    [manager startMonitoring];
}

@end
