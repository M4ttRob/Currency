//
//  MRWikiViewController.m
//  Currency
//
//  Created by Matt Robinson on 4/5/13.
//  Copyright (c) 2013 Matt Robinson. All rights reserved.
//

#import "MRWikiViewController.h"

@implementation MRWikiViewController

- (void)viewDidLoad
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webURL]];
    [self.webView loadRequest:request];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Information"
                          message: @"Swipe left and right to go forward and back!"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Webpage navigation

- (IBAction)webpageBack:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (IBAction)webpageForward:(id)sender
{
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}
@end
