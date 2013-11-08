//
//  QBFeedbackTopicListViewController.h
//  QBFeedback
//
//  Created by Tanaka Katsuma on 2013/11/08.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBFeedbackTopicListViewController;
@class QBFeedbackTopic;

@protocol QBFeedbackTopicListViewControllerDelegate <NSObject>

- (void)topicListViewController:(QBFeedbackTopicListViewController *)topicListViewController didSelectTopic:(QBFeedbackTopic *)topic;

@end

@interface QBFeedbackTopicListViewController : UITableViewController

@property (nonatomic, weak) id<QBFeedbackTopicListViewControllerDelegate> delegate;
@property (nonatomic, copy, readonly) NSArray *topics;
@property (nonatomic, strong) QBFeedbackTopic *selectedTopic;

- (instancetype)initWithTopics:(NSArray *)topics selectedTopic:(QBFeedbackTopic *)selectedTopic;

@end
