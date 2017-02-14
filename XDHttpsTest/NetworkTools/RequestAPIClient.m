//
//  RequestAPIClient.m
//  iWater
//
//  Created by Xudong.ma on 16/5/10.
//  Copyright © 2016年 Xudong.ma. All rights reserved.
//

#import "RequestAPIClient.h"
#import "AFNetworking.h"
#import "NetworkJudgement.h"

#define kRequestTimeOutInterval     8.f //请求超时时限
#define kImageRquestTimeOutInterval 15.f //图片请求超时时限
#define kAssociatedName @"headPic"       //图片本地存储key
#define kRequestPara    @"requestPara"   // JSON请求key

/** 正式环境*/
#define kMainUrl_HTTPS @"https://duoyundong.yoger.cn%@"
/**
 *  获取系统版本
 */
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface RequestAPIClient ()<NSURLSessionDelegate>
{
    AFHTTPSessionManager *_sessionManager;
}

@end

@implementation RequestAPIClient

static id requestAPIClient = nil;

/**
 *  单例
 */
+ (__kindof RequestAPIClient *)APIClientInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!requestAPIClient) {
            requestAPIClient = [[self alloc] init];
        }
    });
    
    return requestAPIClient;
}

#pragma mark -
#pragma mark networkHandler

/**
 *  网络请求 (POST / GET)
 *
 *  @param path         接口拼接路径
 *  @param params       请求体
 *  @param method       get / post
 *  @param successBlock 成功
 *  @param failureBlock 失败
 *  @param refreshBlock 刷新
 */
- (void)sendRequestPath:(NSString *)path
                 params:(NSDictionary *)params
                 method:(NSString *)method
                success:(APISuccessBlock)successBlock
                failure:(APIFailureBlock)failureBlock
                  error:(APIRefreshBlock)refreshBlock
{
    /** 实时监测网络状态*/
    [[NetworkJudgement defaultInstance] judgeNetWorkIsAvailable];
    /** 初始化通知(断网时接收)*/
    [self receiveNotification];
    
    
    NSString *fullPath = [NSString stringWithFormat:kMainUrl_HTTPS, path];
    
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.securityPolicy.allowInvalidCertificates = YES;
    _sessionManager.requestSerializer.timeoutInterval = kRequestTimeOutInterval;
    
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [_sessionManager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", nil]];
    
    // 验证HTTP+SSL证书
    [_sessionManager setSecurityPolicy:[self customSecurityPolicy]];
    
    if ([[method lowercaseString] isEqualToString:@"get"]) {
        
        if(IOS_VERSION <= 7.0f) {
            
            fullPath = [fullPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
        } else {
            
            fullPath = [fullPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        }
        
        
        [_sessionManager GET:fullPath parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self successDataTask:task ResponseObject:responseObject success:successBlock failure:failureBlock refresh:refreshBlock];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [self errorOperation:failureBlock refresh:refreshBlock];
        }];
        
    } else if ([[method lowercaseString] isEqualToString:@"post"]) {
        
        if(IOS_VERSION <= 7.0f) {
            
            fullPath = [fullPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
        } else {
            
            fullPath = [fullPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        }
        
        
        [_sessionManager POST:fullPath parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self successDataTask:task ResponseObject:responseObject success:successBlock failure:failureBlock refresh:responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failureBlock(error);
            
//            [self errorOperation:failureBlock refresh:refreshBlock];
        }];
    }
}

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
              refresh:(APIRefreshBlock)refreshBlock
{
    /** 实时监测网络状态*/
    [[NetworkJudgement defaultInstance] judgeNetWorkIsAvailable];
    /** 初始化通知(断网时接收)*/
    [self receiveNotification];
    
    NSString *fullPath = [NSString stringWithFormat:kMainUrl_HTTPS, path];
    
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.securityPolicy.allowInvalidCertificates = YES;
    _sessionManager.requestSerializer.timeoutInterval = kImageRquestTimeOutInterval;
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [_sessionManager.responseSerializer setAcceptableContentTypes: [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", @"text/plain", nil]];
    
    // 验证HTTP+SSL证书
    [_sessionManager setSecurityPolicy:[self customSecurityPolicy]];
    
    if(IOS_VERSION <= 7.0f) {
        
        fullPath = [fullPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    } else {
        
        fullPath = [fullPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    }
    
    
    [_sessionManager POST:fullPath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i = 0; i < imagesArr.count; i++) {
            
            UIImage *image = imagesArr[i];
            
            if (UIImageJPEGRepresentation(image, 1.0)) {
             
                [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0)
                                            name:@"pic"
                                        fileName:@"userPic.jpeg"
                                        mimeType:@"image/jpeg"];
            }
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"发布进度%lf", 1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self successDataTask:task ResponseObject:responseObject success:successBlock failure:failureBlock refresh:refreshBlock];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failureBlock(error);
        
//        [self errorOperation:failureBlock refresh:refreshBlock];
    }];
}


/**
 *  成功Block对数据进行处理
 *
 *  param task
 *  param responseObject
 *  param successBlock
 *  param failureBlock
 *  param refreshBlock
 */
- (void)successDataTask:(NSURLSessionDataTask *)task
         ResponseObject:(id)responseObject
                success:(APISuccessBlock)successBlock
                failure:(APIFailureBlock)failureBlock
                refresh:(APIRefreshBlock)refreshBlock
{
    if (responseObject && ![responseObject isKindOfClass:[NSNull class]])
    {
        NSString *errcode = [NSString stringWithFormat:@"%@", responseObject[@"errcode"]];
        
        if (0 == [errcode integerValue]) {
            
            successBlock(responseObject);
        
        } else {
            
            failureBlock(responseObject);
            
            if (![responseObject[@"err_info"] hasPrefix:@"参数错误"])
            {
            
            }
        }
    }
}


/**
 *  失败情况数据处理
 *
 *  param failureBlock
 *  param refreshBlock
 */
- (void)errorOperation:(APIFailureBlock)failureBlock
               refresh:(APIRefreshBlock)refreshBlock
{
    [self unkownErrorFeedBack:failureBlock refresh:refreshBlock];
}

- (void)unkownErrorFeedBack:(APIFailureBlock)failureBlock
                    refresh:(APIRefreshBlock)refreshBlock
{
    NSError *errorCustom = [NSError errorWithDomain:@"" code:UnkownError userInfo:[NSDictionary dictionaryWithObject:@"网络异常，请稍候再试" forKey:@"NSLocalizedDescriptionKey"]];
    if (failureBlock) {
        
        failureBlock(errorCustom);
    }
    
    if (refreshBlock) {
        
    }
}

/**
 *  手动实现图片压缩，可以写到分类里，封装成常用方法。按照大小进行比例压缩，改变了图片的size
 *
 *  param srcImage
 *  param imageScale
 *
 *  return
 */
- (UIImage *)makeThumbnailFromImage:(UIImage *)srcImage
                              scale:(double)imageScale
{
    UIImage *thumbnail = nil;
    CGSize imageSize = CGSizeMake(srcImage.size.width * imageScale, srcImage.size.height * imageScale);
    if (srcImage.size.width != imageSize.width || srcImage.size.height != imageSize.height)
    {
        
        UIGraphicsBeginImageContext(imageSize);
        
        CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
        
        [srcImage drawInRect:imageRect];
        
        thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    } else {
        
        thumbnail = srcImage;
        
    }
    
    return thumbnail;
}

/**
 *  通知中心
 *
 *  return 无网状态下触发
 */
- (void)receiveNotification
{
    /*
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(receiveNotification:) name:kNetworkingConnectFailed object:nil];
     
     */
}

- (void)receiveNotification:(NSNotification *)notificationCenter
{
//    [MBProgressHUD showError:@"网络不给力"];
}

- (void)MD5Hash
{
    
}

- (AFSecurityPolicy *)customSecurityPolicy
{
    /* 导入证书 (证书在这里暂时不能公开, 防止盗用, 主要看实现代码吧)**/
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"duoyundong.yoger.cn" ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    /* 如果是需要验证自建证书，需要设置为YES**/
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName      = NO;
    securityPolicy.pinnedCertificates = [NSSet setWithArray:@[certData]];
    
    return securityPolicy;
}

@end
