//
//  QBFeedbackViewController.h
//  QBFeedback
//
//  Created by Tanaka Katsuma on 2013/11/08.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBFeedbackViewController;

@protocol QBFeedbackViewControllerDelegate <NSObject>

@optional
- (void)feedbackViewControllerDidFinishSendingFeedback:(QBFeedbackViewController *)feedbackViewController;
- (void)feedbackViewControllerDidCancelSendingFeedback:(QBFeedbackViewController *)feedbackViewController;

@end

@interface QBFeedbackViewController : UITableViewController

@property (nonatomic, weak) id<QBFeedbackViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL showsCancelButton;

@property (nonatomic, copy) NSArray *toRecipients;
@property (nonatomic, copy) NSArray *ccRecipients;
@property (nonatomic, copy) NSArray *bccRecipients;

+ (BOOL)isAvailable;
+ (NSArray *)defaultTopics;

- (instancetype)initWithTopics:(NSArray *)topics;

@end
