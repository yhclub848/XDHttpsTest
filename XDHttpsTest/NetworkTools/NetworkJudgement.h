//
//  NetworkJudgement.h
//  iWater
//
//  Created by Xudong.ma on 16/5/11.
//  Copyright © 2016年 Xudong.ma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkJudgement : NSObject

/**
 *  单例
 */
+ (__kindof NetworkJudgement *)defaultInstance;

/**
 *  判断网络状态
 */
- (void)judgeNetWorkIsAvailable;

@end
