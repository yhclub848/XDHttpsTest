# XDHttpsTest
这是我在简书发的第一篇技术文章, 在工作间隙我觉得还是有必要把工作中遇到的问题, 包括调研的一些知识点做一个记录, 希望可以对大家有所帮助.
****
长话短说, 直接上干货!
****
ATS是在2015年由苹果引入的强化网络传输安全的标准，要求所有的App在从Web端获取数据的时候都要使用安全的HTTPS链接，并进一步强调要使用最新的TLS1.2版本的HTTPS。
首先需要服务器端升级到https，拿到服务器哥们提供的server.pem证书文件，并导入到项目中

[项目地址](https://github.com/yhclub848/XDHttpsTest)

```
- (AFSecurityPolicy *)customSecurityPolicy
{
    /* 导入证书 (证书在这里暂时不能公开, 防止盗用, 主要看实现代码吧)**/
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"duoyundong.yoger.cn" ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    /* 如果是需要验证自建证书，需要设置为YES**/
    securityPolicy.allowInvalidCertificates  = YES;
    securityPolicy.validatesDomainName  = NO;
    
    /** 如果certData为空会导致崩溃问题, 这里需要加一个判断*/
    if (certData) {
        securityPolicy.pinnedCertificates = [NSSet setWithArray:@[certData]];
    }
    return securityPolicy;
}
```

/*** 具体还是下载测试项目, 代码以项目为准 ***/

```
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
```

AFN常见错误
```
//1.创建一个管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    //1.0 改请求的默认的序列化方式 改成JSON格式的请求（请求为json格式的二进制）
//会把字典，数组转化成json格式的二进制传给服务器。
//默认情况下是普通的二进制，实现此方法改为JSON格式的二进制
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    //1.1 改默认的响应反序列化方式 改为普通二进制（服务器返回的是二进制，afn不做处理）。
//默认情况下 afn会做二进制转为json的格式的处理。然后我们自己把json转成数组，或字典。
//实现此方法后不做处理，直接将二进制说句给你。也不再需要1.2 增加默认的返回方式(JSON)的可接收的类型。
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    //1.2 增加默认的返回方式(JSON)的可接收的类型
    //manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
```

常见问题
注意：如果服务器升级到TLS1.1还是不行的，因为苹果要求使用TLS1.2 SSL加密请求数据。会造成无法接受数据
