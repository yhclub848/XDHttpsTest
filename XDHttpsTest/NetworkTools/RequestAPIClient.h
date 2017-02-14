//
//  RequestAPIClient.h
//  iWater
//
//  Created by Xudong.ma on 16/5/10.
//  Copyright © 2016年 Xudong.ma. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  网络请求错误状态
 */
typedef NS_ENUM(NSInteger, errorCode) {

    NormalError = 10000, //正常类型
    UnkownError = 20000, //未知类型
};

#pragma mark - 创建网络请求使用的三种Block

typedef void (^APISuccessBlock)(id responseObject); //成功状态
typedef void (^APIFailureBlock)(NSError * error); // 失败状态
typedef void (^APIRefreshBlock)(void); //刷新

@interface RequestAPIClient : NSObject

/**
 *  网络请求单例
 */
+ (__kindof RequestAPIClient *)APIClientInstance;

/**
 *  网络请求 (POST / GET)
 *
 *  @param path         接口拼接路径
 *  @param params       请求体
 *  @param method       "get" / "post"
 *  @param successBlock 成功
 *  @param failureBlock 失败
 *  @param refreshBlock 刷新
 */
- (void)sendRequestPath:(NSString *)path
                 params:(NSDictionary *)params
                 method:(NSString *)method
                success:(APISuccessBlock)successBlock
                failure:(APIFailureBlock)failureBlock
                  error:(APIRefreshBlock)refreshBlock;



/**
 *  图片上传网络请求
 *
 *  @param path         接口拼接路径
 *  @param params       请求体
 *  @param imagesArr    图片数据
 *  @param successBlock 成功
 *  @param failureBlock 失败
 *  @param refreshBlock 刷新
 */
- (void)uploadIMGPath:(NSString *)path
               params:(NSDictionary *)params
            imagesArr:(NSArray *)imagesArr
         imagesArrKey:(NSString *)imagesArrKey
              success:(APISuccessBlock)successBlock
              failure:(APIFailureBlock)failureBlock
              refresh:(APIRefreshBlock)refreshBlock;

@end
