//
//  MRViewController.m
//  Currency
//
//  Created by Matt Robinson on 4/4/13.
//  Copyright (c) 2013 Matt Robinson. All rights reserved.
//

#import "MRViewController.h"
#import "MRCurrencyConverter.h"
#import "MRPickerView.h"
#import "MRWikiViewController.h"

@interface MRViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (nonatomic) NSUInteger threadCount;

@property (weak, nonatomic) IBOutlet UITextField *amountOutput1;
@property (weak, nonatomic) IBOutlet UITextField *amountOutput2;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) MRCurrencyConverter *converter;
@end

@implementation MRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.picker.delegate = self;
    self.threadCount = 0;
    
    [self.picker selectRow:0 inComponent:0 animated:TRUE];
    [self.picker selectRow:0 inComponent:1 animated:TRUE];
    
    [self.amountOutput2 setUserInteractionEnabled:NO];
    
    self.converter.currencyKeyFrom = @"AUD";
    self.converter.currencyKeyTo = @"AUD";
    self.converter.currencyFromAmount = 1.0f;
    self.converter.currencyToAmount = 1.0f;
    
    self.dateLabel.text = [NSString stringWithFormat:@"Updated: %@", self.converter.dataRetrieved];
	
    NSLog(@"Welcome to the Currency converter...\n");
}

#pragma mark - View lifecycle

- (MRCurrencyConverter *)converter
{
    if (!_converter) {
        _converter = [[MRCurrencyConverter alloc] init];
    }
    return _converter;
}

#pragma mark - View management

- (IBAction)dismissKeyboard:(id)sender {
    [self.amountOutput1 resignFirstResponder];
    if ([self.amountOutput1.text isEqualToString:@""]) {
        self.converter.currencyFromAmount = 1.0f;
        self.amountOutput1.text = @"";
        self.amountOutput2.text = @"";
    } else {
        self.converter.currencyFromAmount = [self.amountOutput1.text floatValue];
        NSString *amount = [NSString stringWithFormat:@"%.2f", [self.converter convertStoredData]];
        self.amountOutput1.text = [NSString stringWithFormat:@"%.2f", self.converter.currencyFromAmount];
        self.amountOutput2.text = amount;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"WikiView"]) {
        MRWikiViewController *webViewCont = [segue destinationViewController];
        webViewCont.title = self.converter.currencyKeyTo;
        webViewCont.webURL = [NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", self.converter.currencyKeyTo];
    }
}

#pragma mark - Update model

- (IBAction)updateConversionRates:(id)sender
{
    NSLog(@"Updating conversion rates...");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.threadCount++;
    
    [self.converter updateCurrencyRates:^(NSDictionary *returnData) {
        NSString *newDate = [NSString stringWithFormat:@"Updated: %@", self.converter.dataRetrieved];
        NSString *oldDate = self.dateLabel.text;
        
        self.threadCount--;
        if (!self.threadCount)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *todaysDate = [NSString stringWithFormat:@"Updated: %@", [dateFormat stringFromDate:[NSDate date]]];
        
        if (![newDate isEqualToString:todaysDate]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Alert"
                                  message: @"Internet connectivity issues! Couldn't get updated currency exchange rates."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            NSLog(@"Network issues...");
        } else if ([newDate isEqualToString:oldDate]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Alert"
                                  message: @"Currency exchanges rates are up to date!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            NSLog(@"Conversion rates already current...");
        } else {
            self.dateLabel.text = [NSString stringWithFormat:@"Updated: %@", self.converter.dataRetrieved];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Alert"
                                  message: @"Currency exchanges rates have been updated!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            NSLog(@"Updated conversion rates...");
        }
    }];
    
    if ([[self.converter.currencyRates allKeys] count]) {
        [self.picker reloadAllComponents];
        self.picker.hidden = NO;
    }
}

#pragma mark - Picker view delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *sortedKeys = [[self.converter.currencyRates allKeys] sortedArrayUsingSelector:@selector(compare:)];
    id aKey = [sortedKeys objectAtIndex:row];
    
    if (component == 0) {
        self.amountOutput1.text = aKey;
        self.converter.currencyKeyFrom = aKey;
    } else {
        self.amountOutput2.text = aKey;
        self.converter.currencyKeyTo = aKey;
    }
    
    NSString *amount = [NSString stringWithFormat:@"%.2f", [self.converter convertStoredData]];
    
    self.amountOutput1.text = [NSString stringWithFormat:@"%.2f", self.converter.currencyFromAmount];
    self.amountOutput2.text = amount;
    
    NSLog(@"Row: %d    Column: %d", row, component);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *keys = [self.converter.currencyRates allKeys];
    return [keys count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    
    NSArray *sortedKeys = [[self.converter.currencyRates allKeys] sortedArrayUsingSelector: @selector(compare:)];
    id aKey = [sortedKeys objectAtIndex:row];
    
    title = [aKey description];
    
    return title;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 150;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(MRPickerView *)view
{
    NSArray *sortedKeys = [[self.converter.currencyRates allKeys] sortedArrayUsingSelector:@selector(compare:)];
    id aKey = [sortedKeys objectAtIndex:row];
    MRPickerView *tempView;
    
    UIImage *flagImage = [UIImage imageNamed:aKey];
    NSString *flagText = aKey;
    
    if ([[UIScreen mainScreen] scale] >= 2.0)
        flagText = [flagText stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
    
    if(view) {
        tempView = view;
        tempView.flagText.text = flagText;
        tempView.flagImage.image = flagImage;
    } else {
        tempView = [[MRPickerView alloc] initWithImage:flagImage withText:flagText];
    }
    
    return tempView;
}

@end
