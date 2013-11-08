//
//  QBFeedbackPlaceholderTextView.m
//  QBFeedback
//
//  Created by Tanaka Katsuma on 2013/11/08.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "QBFeedbackPlaceholderTextView.h"

@interface QBFeedbackPlaceholderTextView ()

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation QBFeedbackPlaceholderTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    // Add placeholder label
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    placeholderLabel.numberOfLines = 0;
    placeholderLabel.backgroundColor = [UIColor clearColor];
    placeholderLabel.textColor = [UIColor lightGrayColor];
    
    self.placeholderLabel = placeholderLabel;
    [self addSubview:self.placeholderLabel];
    
    // Register notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    // Remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:nil];
}


#pragma mark - Accessors

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self updatePlaceholder];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    [self updatePlaceholder];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    [self updatePlaceholder];
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    self.placeholderLabel.text = placeholderText;
    
    [self updatePlaceholder];
}

- (NSString *)placeholderText
{
    return self.placeholderLabel.text;
}


#pragma mark - Notification

- (void)textViewDidChange:(NSNotification *)notification
{
    [self updatePlaceholder];
}


#pragma mark - Updating the View

- (CGRect)placeholderLabelFrame
{
    CGFloat leftMargin;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        leftMargin = 5.0;
    } else {
        leftMargin = 8.0;
    }
    
    return CGRectMake(leftMargin,
                      8.5,
                      self.bounds.size.width - leftMargin * 2.0,
                      ceil(self.font.lineHeight));
}

- (void)updatePlaceholder
{
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.frame = [self placeholderLabelFrame];
    self.placeholderLabel.alpha = (self.text.length > 0) ? 0.0 : 1.0;
}

@end
