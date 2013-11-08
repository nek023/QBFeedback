//
//  QBFeedbackTopic.h
//  QBFeedback
//
//  Created by Tanaka Katsuma on 2013/11/08.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBFeedbackTopic : NSObject

@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) NSString *table;

+ (instancetype)topicWithKey:(NSString *)key table:(NSString *)table;
- (instancetype)initWithKey:(NSString *)key table:(NSString *)table;

@end
