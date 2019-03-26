//
//  BVerifyManager.m
//  BVerifyClient
//
//  Created by Gert-Jaap Glasbergen on 26/03/2019.
//  Copyright © 2019 Gert-Jaap Glasbergen. All rights reserved.
//

#import "BVerifyManager.h"
#import "Mobile/Mobile.h"

@implementation BVerifyManager
+(void)startClient {
    NSError *err;
    MobileRunBVerifyClient(@"bverify.org",15901,&err);
    NSLog(@"%@",err);
}

+(void)getStatus:(void(^)(BVerifyStatus*))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *urlPath = [NSURL URLWithString:@"http://localhost:8001/status"];
        NSError *err;
        NSData *jsonData = [NSData dataWithContentsOfURL:urlPath options:NSDataReadingUncached error:&err];
        if(jsonData == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                callback(nil);
            });
        } else {
            NSError *error = nil;
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                //stop your HUD here
                //This is run on the main thread
                BVerifyStatus *status = [[BVerifyStatus alloc] init];
                status.synced =  [dataDictionary[@"synced"] boolValue];
                status.blockHeight = dataDictionary[@"blockHeight"];
                callback(status);
            });
        }
    });
    
}

+(void)verifyOnce:(NSString *)base64Proof withCallback:(void(^)(BVerifyVerificationResult*))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8001/verifyonce"]];
        request.HTTPMethod = @"POST";
        [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        NSData *requestBodyData = [base64Proof dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *jsonData, NSURLResponse *response, NSError *error) {
            if(jsonData == nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    callback(nil);
                });
            } else {
                NSError *error = nil;
                NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    BVerifyVerificationResult *result = [[BVerifyVerificationResult alloc] init];
                    result.statement = dataDictionary[@"Statement"];
                    result.blockHash =  dataDictionary[@"BlockHash"];
                    result.txHash =  dataDictionary[@"TxHash"];
                    result.error =  dataDictionary[@"StateErrorment"];
                    result.valid = [dataDictionary[@"Valid"] boolValue];
                    result.pubKey = dataDictionary[@"PubKey"];
                    result.time = [NSDate dateWithTimeIntervalSince1970:[dataDictionary[@"BlockTimestamp"] intValue]];
                    callback(result);
                });
            }
        }];
        
        [task resume];
    
    
    });
    
}

+(void)addForeignLog:(NSString *)base64Proof withCallback:(void(^)(bool))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8001/addforeignlog"]];
        request.HTTPMethod = @"POST";
        [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        NSData *requestBodyData = [base64Proof dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *jsonData, NSURLResponse *response, NSError *error) {
            if(jsonData == nil) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    callback(false);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    callback(true);
                });
            }
        }];
        
        [task resume];
        
        
    });
    
}

+(void)getLogs:(void(^)(NSArray*))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *urlPath = [NSURL URLWithString:@"http://localhost:8001/logs"];
        NSError *err;
        NSData *jsonData = [NSData dataWithContentsOfURL:urlPath options:NSDataReadingUncached error:&err];
        if(jsonData == nil) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                callback(nil);
            });
        } else {
            NSError *error = nil;
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                NSMutableArray *returnArr = [[NSMutableArray alloc] init];
                
                for(NSDictionary *dict in arr) {
                    BVerifyLog *log = [[BVerifyLog alloc] init];
                    log.foreign =  [dict[@"Foreign"] boolValue];
                    log.logID =  dict[@"LogID"];
                    log.lastStatement =  dict[@"LastStatement"];
                    log.lastIndex =  dict[@"LastIndex"];
                    log.lastCommitment =  dict[@"LastCommitment"];
                    log.lastCommitmentBlock =  dict[@"LastCommitmentBlock"];
                    log.lastCommitmentTimestamp = [NSDate dateWithTimeIntervalSince1970:[dict[@"LastCommitmentTimestamp"] intValue]];
                    log.valid =  [dict[@"Valid"] boolValue];
                    log.error =  dict[@"Error"];
                    [returnArr addObject:log];
                }
                
                callback(returnArr);
            });
        }
        
        
        
    });
    
}
@end

@implementation BVerifyStatus

@end

@implementation BVerifyLog

@end

@implementation BVerifyVerificationResult

@end
