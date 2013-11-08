//
//  QBFeedbackTopic.m
//  QBFeedback
//
//  Created by Tanaka Katsuma on 2013/11/08.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "QBFeedbackTopic.h"

@interface QBFeedbackTopic ()

@property (nonatomic, copy, readwrite) NSString *key;
@property (nonatomic, copy, readwrite) NSString *table;

@end

@implementation QBFeedbackTopic

+ (instancetype)topicWithKey:(NSString *)key table:(NSString *)table
{
    return [[self alloc] initWithKey:key table:table];
}

- (instancetype)initWithKey:(NSString *)key table:(NSString *)table
{
    self = [super init];
    
    if (self) {
        self.key = key;
        self.table = (table != nil) ? table : @"Localizable";
    }
    
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    
    if (![self.key isEqualToString:[other key]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash
{
    return [self.key hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; key = %@; table = %@>",
            NSStringFromClass([self class]),
            self,
            self.key,
            self.table
            ];
}

@end
