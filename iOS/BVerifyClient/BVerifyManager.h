//
//  BVerifyManager.h
//  BVerifyClient
//
//  Created by Gert-Jaap Glasbergen on 26/03/2019.
//  Copyright © 2019 Gert-Jaap Glasbergen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface BVerifyStatus : NSObject

@property NSNumber *blockHeight;
@property bool synced;

@end

@interface BVerifyVerificationResult : NSObject


@property NSString *statement;
@property bool valid;
@property NSString *error;
@property NSString *pubKey;
@property NSString *blockHash;
@property NSString *txHash;
@property NSDate *time;
@end

@interface BVerifyLog : NSObject
@property bool foreign;
@property NSString *logID;
@property NSString *lastStatement;
@property NSNumber *lastIndex;
@property NSString *lastCommitment;
@property NSString *lastCommitmentBlock;
@property NSDate *lastCommitmentTimestamp;
@property bool valid;
@property NSString *error;
@end

@interface BVerifyManager : NSObject
+(void)startClient;
+(void)addForeignLog:(NSString *)base64Proof withCallback:(void(^)(bool))callback;
+(void)getStatus:(void(^)(BVerifyStatus*))callback;
+(void)verifyOnce:(NSString *)base64Proof withCallback:(void(^)(BVerifyVerificationResult*))callback;
+(void)getLogs:(void(^)(NSArray*))callback;
@end



NS_ASSUME_NONNULL_END
