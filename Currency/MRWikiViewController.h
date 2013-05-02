//
//  MRWikiViewController.h
//  Currency
//
//  Created by Matt Robinson on 4/5/13.
//  Copyright (c) 2013 Matt Robinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRWikiViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *webURL;
@end
