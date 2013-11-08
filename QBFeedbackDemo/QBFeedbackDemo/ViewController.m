//
//  ViewController.m
//  QBFeedbackDemo
//
//  Created by Tanaka Katsuma on 2013/11/08.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign, getter = isModal) BOOL modal;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBFeedbackViewController *feedbackViewController = [[QBFeedbackViewController alloc] init];
    feedbackViewController.delegate = self;
    feedbackViewController.toRecipients = @[@"questbeat@gmail.com"];
    
    if (indexPath.row == 0) {
        self.modal = NO;
        
        [self.navigationController pushViewController:feedbackViewController animated:YES];
    } else {
        self.modal = YES;
        
        feedbackViewController.showsCancelButton = YES;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}


#pragma mark - QBFeedbackViewControllerDelegate

- (void)feedbackViewControllerDidFinishSendingFeedback:(QBFeedbackViewController *)feedbackViewController
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)feedbackViewControllerDidCancelSendingFeedback:(QBFeedbackViewController *)feedbackViewController
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
