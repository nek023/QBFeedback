//
//  QBFeedbackTopicListViewController.m
//  QBFeedback
//
//  Created by Tanaka Katsuma on 2013/11/08.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "QBFeedbackTopicListViewController.h"

#import "QBFeedbackTopic.h"

@interface QBFeedbackTopicListViewController ()

@property (nonatomic, copy, readwrite) NSArray *topics;

@end

@implementation QBFeedbackTopicListViewController

- (instancetype)initWithTopics:(NSArray *)topics selectedTopic:(QBFeedbackTopic *)selectedTopic
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.topics = topics;
        self.selectedTopic = selectedTopic;
    }
    
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Title
    self.title = NSLocalizedStringFromTable(@"QBFeedbackTopicListViewControllerTitle", @"QBFeedback", nil);
}


#pragma mark - Helper

- (UIColor *)cellHighlightedTextColor
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return [UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    QBFeedbackTopic *topic = [self.topics objectAtIndex:indexPath.row];
    cell.textLabel.text = NSLocalizedStringFromTable(topic.key, topic.table, nil);
    
    if ([topic isEqual:self.selectedTopic]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [self cellHighlightedTextColor];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove checkmark from previous selected cell
    NSUInteger rowIndex = [self.topics indexOfObject:self.selectedTopic];
    UITableViewCell *previousSelectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
    previousSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    previousSelectedCell.textLabel.textColor = [UIColor blackColor];
    
    // Add checkmark to selected cell
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    selectedCell.textLabel.textColor = [self cellHighlightedTextColor];
    
    // Update selected topic
    QBFeedbackTopic *topic = [self.topics objectAtIndex:indexPath.row];
    self.selectedTopic = topic;
    
    // Delegate
    [self.delegate topicListViewController:self didSelectTopic:topic];
    
    // Deselect selected row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
