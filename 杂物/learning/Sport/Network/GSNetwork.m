//
//  GSNetwork.m
//  GSNetwork
//
//  Created by qiuhaodong on 16/5/30.
//  Copyright © 2016年 qiuhaodong. All rights reserved.
//

#import "GSNetwork.h"
#import "AFNetworking.h"
#import "GSNetworkAssist.h"

@interface GSNetwork()
@property (strong, nonatomic) AFHTTPSessionManager *afHTTPSessionManager;
@end

@implementation GSNetwork

#pragma mark - 公开方法

/*因为AF的处理，回调的block已经会在主线程执行*/

+ (NSURLSessionTask *)getWithBasicUrlString:(NSString *)basicUrlString
                                 parameters:(NSDictionary *)parameters
                            responseHandler:(GSNetworkResponseHandler)responseHandler {
    
    NSMutableDictionary *mutableParameters =  [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([GSNetworkAssist checkTokenNetworkReq:mutableParameters] == NO){

        //开子线程重试
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getWithBasicUrlString:basicUrlString parameters:mutableParameters responseHandler:responseHandler];
        });

        //[self handleResponseWithHandler:responseHandler jsonResult:reDic task:nil];
        return nil;
    }
    
    [GSNetwork shareManager].afHTTPSessionManager.requestSerializer.timeoutInterval = 30.0;
    NSURLSessionTask *task = [[GSNetwork shareManager].afHTTPSessionManager GET:basicUrlString parameters:[GSNetworkAssist addCommonParameters:mutableParameters] progress:
                              ^(NSProgress * _Nonnull downloadProgress) {
                                  
                              } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [self handleResponseWithHandler:responseHandler jsonResult:responseObject task:task];
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  [self handleResponseWithHandler:responseHandler jsonResult:nil task:task];
                              }];
    
    return task;
}

/*
 post方法
 Content-Type为application/x-www-form-urlencoded
 */
+ (NSURLSessionTask *)postWithBasicUrlString:(NSString *)basicUrlString
                                  parameters:(NSDictionary *)parameters
                             responseHandler:(GSNetworkResponseHandler)responseHandler {
    if ([GSNetworkAssist checkTokenNetworkReq:parameters] == NO){
        NSDictionary *reDic = @{PARA_STATUS:STATUS_UKNOW_ERROR, PARA_MSG:@"系统繁忙，请稍后再试"};
        [self handleResponseWithHandler:responseHandler jsonResult:reDic task:nil];
        return nil;
    }
    
    [GSNetwork shareManager].afHTTPSessionManager.requestSerializer.timeoutInterval = 30.0;
    NSURLSessionTask *task = [[GSNetwork shareManager].afHTTPSessionManager POST:basicUrlString parameters:[GSNetworkAssist addCommonParameters:parameters] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleResponseWithHandler:responseHandler jsonResult:responseObject task:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseWithHandler:responseHandler jsonResult:nil task:task];
    }];
    
    return task;
}

/*
 post图片方法
 Content-Type为multipart/form-data
 */
+ (NSURLSessionTask *)postWithBasicUrlString:(NSString *)basicUrlString
                                  parameters:(NSDictionary *)parameters
                                       image:(UIImage *)image
                             responseHandler:(GSNetworkResponseHandler)responseHandler {
    if ([GSNetworkAssist checkTokenNetworkReq:parameters] == NO){
        NSDictionary *reDic = @{PARA_STATUS:STATUS_UKNOW_ERROR, PARA_MSG:@"系统繁忙，请稍后再试"};
        [self handleResponseWithHandler:responseHandler jsonResult:reDic task:nil];
        return nil;
    }
    
    NSString *query = AFQueryStringFromParameters([GSNetworkAssist addCommonParameters:parameters]);
    NSString *url = [NSString stringWithFormat:@"%@?%@", basicUrlString, query];
    NSURLSessionTask *task = [[GSNetwork shareManager].afHTTPSessionManager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (image) {
            NSData *data = nil;
            int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
            BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                              alphaInfo == kCGImageAlphaNoneSkipFirst ||
                              alphaInfo == kCGImageAlphaNoneSkipLast);
            BOOL imageIsPng = hasAlpha;
            if (imageIsPng) {
                data = UIImagePNGRepresentation(image);
            }
            else {
                data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
            }
            
            NSString *time = [NSString stringWithFormat:@"%@.%@", [@([[NSDate date] timeIntervalSince1970]) stringValue], (imageIsPng ? @"png" : @"jpg") ];
            [formData appendPartWithFileData:data name:@"uploadedfile" fileName:time mimeType:@"application/octet-stream"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleResponseWithHandler:responseHandler jsonResult:responseObject task:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseWithHandler:responseHandler jsonResult:nil task:task];
    }];
    
    return task;
}


#pragma mark - 私有方法
static GSNetwork *_GSNetwork = nil;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _GSNetwork = [[GSNetwork alloc] init];
        _GSNetwork.afHTTPSessionManager = [AFHTTPSessionManager manager];
    });
    return _GSNetwork;
}

+ (void)handleResponseWithHandler:(GSNetworkResponseHandler)handler
                       jsonResult:(NSDictionary *)jsonResult
                             task:(NSURLSessionTask *)task {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *afterCheckResult = [GSNetworkAssist checkResult:jsonResult response:task.response];
        if (handler) {
            GSNetworkResponse *r = [[GSNetworkResponse alloc] initWithJsonResult:afterCheckResult response:task.response];
            handler(r);
        }
    });
}

+ (NSArray *)allTasks {
    return [GSNetwork shareManager].afHTTPSessionManager.tasks;
}

@end
