//
//  QBFeedbackViewController.m
//  QBFeedback
//
//  Created by Tanaka Katsuma on 2013/11/08.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "QBFeedbackViewController.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "QBFeedbackTopicListViewController.h"
#import "QBFeedbackTopic.h"
#import "QBFeedbackPlaceholderTextView.h"

@interface QBFeedbackViewController () <QBFeedbackTopicListViewControllerDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, copy, readwrite) NSArray *topics;
@property (nonatomic, strong, readwrite) QBFeedbackTopic *selectedTopic;

@property (nonatomic, strong) QBFeedbackPlaceholderTextView *descriptionTextView;

@end

@implementation QBFeedbackViewController

+ (BOOL)isAvailable
{
    return [MFMailComposeViewController canSendMail];
}

+ (NSArray *)defaultTopics
{
    return @[
             [QBFeedbackTopic topicWithKey:@"QBFeedbackTopicQuestion" table:@"QBFeedback"],
             [QBFeedbackTopic topicWithKey:@"QBFeedbackTopicRequest" table:@"QBFeedback"],
             [QBFeedbackTopic topicWithKey:@"QBFeedbackTopicBugReport" table:@"QBFeedback"],
             [QBFeedbackTopic topicWithKey:@"QBFeedbackTopicMedia" table:@"QBFeedback"],
             [QBFeedbackTopic topicWithKey:@"QBFeedbackTopicBusiness" table:@"QBFeedback"],
             [QBFeedbackTopic topicWithKey:@"QBFeedbackTopicOther" table:@"QBFeedback"]
             ];
}

- (instancetype)init
{
    return [self initWithTopics:nil];
}

- (instancetype)initWithTopics:(NSArray *)topics
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        if (topics) {
            self.topics = topics;
        } else {
            self.topics = [[self class] defaultTopics];
        }
        
        self.selectedTopic = (self.topics.count > 0) ? [self.topics objectAtIndex:0] : nil;
    }
    
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Title
    self.title = NSLocalizedStringFromTable(@"QBFeedbackViewControllerTitle", @"QBFeedback", nil);
    
    // Send button
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"QBFeedbackButtonSend", @"QBFeedback", nil)
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(send:)];
    [self.navigationItem setRightBarButtonItem:sendButton animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Update table view
    [self.tableView reloadData];
}


#pragma mark - Accessors

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    
    if (self.showsCancelButton) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(cancel:)];
        [self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    }
}

- (QBFeedbackPlaceholderTextView *)descriptionTextView
{
    if (_descriptionTextView == nil) {
        _descriptionTextView = [[QBFeedbackPlaceholderTextView alloc] init];
        _descriptionTextView.delegate = self;
        _descriptionTextView.scrollEnabled = NO;
        _descriptionTextView.backgroundColor = [UIColor clearColor];
        _descriptionTextView.font = [UIFont systemFontOfSize:17.0];
        _descriptionTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _descriptionTextView.placeholderText = NSLocalizedStringFromTable(@"QBFeedbackDescriptionPlaceholder", @"QBFeedback", nil);
    }
    
    return _descriptionTextView;
}


#pragma mark - Actions

- (void)cancel:(id)sender
{
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedbackViewControllerDidCancelSendingFeedback:)]) {
        [self.delegate feedbackViewControllerDidCancelSendingFeedback:self];
    }
}

- (void)send:(id)sender
{
    [self.descriptionTextView resignFirstResponder];
    
    // Create mail composer
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    
    [mailComposeViewController setToRecipients:self.toRecipients];
    [mailComposeViewController setCcRecipients:self.ccRecipients];
    [mailComposeViewController setBccRecipients:self.bccRecipients];
    
    NSString *subject = [NSString stringWithFormat:@"%@: %@",
                         [self displayName],
                         NSLocalizedStringFromTable(self.selectedTopic.key, self.selectedTopic.table, nil)];
    [mailComposeViewController setSubject:subject];
    
    NSString *messageBody = [NSString stringWithFormat:@"%@\n\n\n%@:\n%@\n\n%@:\n%@\n\n%@:\n%@ %@",
                             self.descriptionTextView.text,
                             NSLocalizedStringFromTable(@"QBFeedbackDeviceText", @"QBFeedback", nil),
                             [self platformName],
                             NSLocalizedStringFromTable(@"QBFeedbackiOSText", @"QBFeedback", nil),
                             [[UIDevice currentDevice] systemVersion],
                             NSLocalizedStringFromTable(@"QBFeedbackAppNameText", @"QBFeedback", nil),
                             [self displayName],
                             [self version]];
    [mailComposeViewController setMessageBody:messageBody isHTML:NO];
    
    [self presentViewController:mailComposeViewController animated:YES completion:NULL];
}


#pragma mark - Getting Information

- (NSString *)platform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    
    free(machine);
    
    return platform;
}

- (NSString *)platformName
{
    NSString *platform = [self platform];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (GSM)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (GSM Rev A)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (Global)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (Global)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (Wi‑Fi Rev A)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad mini 2G (Cellular)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
}

- (NSString *)displayName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

- (NSString *)version
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        // Create cell
        switch (indexPath.section) {
            case 0:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                        
                    case 1:
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            case 1:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
                
            default:
                break;
        }
    }
    
    // Configure cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedStringFromTable(@"QBFeedbackTopicText", @"QBFeedback", nil);
                    cell.detailTextLabel.text = NSLocalizedStringFromTable(self.selectedTopic.key, self.selectedTopic.table, nil);
                }
                    break;
                    
                case 1:
                {
                    CGFloat margin = [self descriptionTextViewMargin];
                    self.descriptionTextView.frame = CGRectMake(margin, 0, cell.contentView.bounds.size.width - margin * 2.0, cell.contentView.bounds.size.height);
                    [cell.contentView addSubview:self.descriptionTextView];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedStringFromTable(@"QBFeedbackDeviceText", @"QBFeedback", nil);
                    cell.detailTextLabel.text = [self platformName];
                }
                    break;
                    
                case 1:
                {
                    cell.textLabel.text = NSLocalizedStringFromTable(@"QBFeedbackiOSText", @"QBFeedback", nil);
                    cell.detailTextLabel.text = [[UIDevice currentDevice] systemVersion];
                }
                    break;
                    
                case 2:
                {
                    cell.textLabel.text = NSLocalizedStringFromTable(@"QBFeedbackAppNameText", @"QBFeedback", nil);
                    cell.detailTextLabel.text = [self displayName];
                }
                    break;
                    
                case 3:
                {
                    cell.textLabel.text = NSLocalizedStringFromTable(@"QBFeedbackVersionText", @"QBFeedback", nil);
                    cell.detailTextLabel.text = [self version];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return NSLocalizedStringFromTable(@"QBFeedbackTableHeaderTopic", @"QBFeedback", nil);
        }
            break;
            
        case 1:
        {
            return NSLocalizedStringFromTable(@"QBFeedbackTableHeaderBasicInfo", @"QBFeedback", nil);
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (CGFloat)descriptionTextViewMargin
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return 10.0;
    } else {
        return 2.0;
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)attributedText width:(CGFloat)width
{
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:attributedText];
    
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, 1000.0)];
    
    return size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.descriptionTextView.text
                                                                             attributes:@{ NSFontAttributeName : self.descriptionTextView.font }];
        CGFloat margin = [self descriptionTextViewMargin];
        CGFloat height = [self textViewHeightForAttributedText:attributedText width:(self.view.bounds.size.width - margin * 2.0)];
        
        return MAX(88.0, ceil(height) + 1.0);
    }
    
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.descriptionTextView resignFirstResponder];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    
                    // Open topic list
                    QBFeedbackTopicListViewController *topicListViewController = [[QBFeedbackTopicListViewController alloc] initWithTopics:self.topics
                                                                                                                             selectedTopic:self.selectedTopic];
                    topicListViewController.delegate = self;
                    
                    [self.navigationController pushViewController:topicListViewController animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - QBFeedbackTopicViewControllerDelegate

- (void)topicListViewController:(QBFeedbackTopicListViewController *)topicViewController didSelectTopic:(QBFeedbackTopic *)topic
{
    self.selectedTopic = topic;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    // Kind of magic
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
        {
            // Close mail composer
            [self dismissViewControllerAnimated:YES
                                     completion:^{
                                         // Delegate
                                         if (self.delegate && [self.delegate respondsToSelector:@selector(feedbackViewControllerDidFinishSendingFeedback:)]) {
                                             [self.delegate feedbackViewControllerDidFinishSendingFeedback:self];
                                         }
                                     }];
        }
            break;
            
        case MFMailComposeResultFailed:
        {
            // Show error
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:NSLocalizedStringFromTable(@"QBFeedbackErrorText", @"QBFeedback", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
        }
            // Fall through
            
        default:
        {
            // Close mail composer
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
            break;
    }
    
}

@end
