//
//  MRCurrencyConverter.m
//  Currency
//
//  Created by Matt Robinson on 4/4/13.
//  Copyright (c) 2013 Matt Robinson. All rights reserved.
//

#import "MRCurrencyConverter.h"

#define currencyUpdateURL @"http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml"
#define savedCurrencyFile @"CurrencyRates.xml"
#define startingCount 34

@interface MRCurrencyConverter()
@property (strong, nonatomic) NSMutableDictionary *currencyRates;
@property (strong, nonatomic) NSString *dataRetrieved;
@end

@implementation MRCurrencyConverter

- (MRCurrencyConverter *)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _currencyRates = [defaults objectForKey:@"rates"];
        _dataRetrieved = [defaults objectForKey:@"date"];
        
        self.currencyToAmount = 1.0f;
        self.currencyFromAmount = 1.0f;
        
        if(!_currencyRates || !_dataRetrieved) {
            [self allocCurrencyAndDate];
            NSLog(@"Taken from disk!");
            [self updateCurrencyRatesFromDisk];
        }
    }
    return self;
}

#pragma mark - Alloc of properties

- (NSMutableDictionary *)currencyRates
{
    if (!_currencyRates) {
        _currencyRates = [[NSMutableDictionary alloc] initWithCapacity:startingCount];
    }
    return _currencyRates;
}

- (NSString *)dataRetrieved
{
    if (!_dataRetrieved) {
        _dataRetrieved = [[NSString alloc] init];
    }
    return _dataRetrieved;
}

- (void)allocCurrencyAndDate
{
    if (!_currencyRates)
        _currencyRates = [[NSMutableDictionary alloc] initWithCapacity:34];
    if (!_dataRetrieved)
        _dataRetrieved = [[NSString alloc] init];
}

#pragma mark - Updating from the web

- (void)updateCurrencyRatesFromDisk
{
    NSData *response = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:savedCurrencyFile]];
    
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:response];
    
    [parser setDelegate:self];
    [parser parse];
    
    [self.currencyRates setObject:[NSNumber numberWithFloat:1.0f] forKey:@"EUR"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.dataRetrieved forKey:@"date"];
    [defaults setObject:self.currencyRates forKey:@"rates"];
}

- (void)updateCurrencyRates:(void (^)(NSDictionary*))block
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("fetch", NULL);
    dispatch_async(downloadQueue, ^{
        [self grabXMLFileFromServer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.currencyRates);
        });
    });
}

#pragma mark - XML grabbing and parsing

- (void)grabXMLFileFromServer
{
    NSURL *currencyData = [NSURL URLWithString:currencyUpdateURL];
    NSData *response = [NSData dataWithContentsOfURL:currencyData];
    
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:response];
    
    [parser setDelegate:self];
    [parser parse];
    
    [self.currencyRates setObject:[NSNumber numberWithFloat:1.0f] forKey:@"EUR"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.dataRetrieved forKey:@"date"];
    [defaults setObject:self.currencyRates forKey:@"rates"];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"Cube"] && [attributeDict count]) {
        NSString *currency = [attributeDict valueForKey:@"currency"];
        NSString *rate = [attributeDict valueForKey:@"rate"];
        NSString *time = [attributeDict valueForKey:@"time"];
        if (time) {
            self.dataRetrieved = time;
            NSLog(@"Date: %@", time);
        } else {
            [self.currencyRates setObject:[NSNumber numberWithFloat:[rate floatValue]] forKey:currency];
            NSLog(@"%@ %@", currency, [NSNumber numberWithFloat:[rate floatValue]]);
        }
    }
}

#pragma mark - Currency conversion

- (CGFloat)convertTo:(NSString *)toKey fromAmount:(CGFloat)fromAmount fromKey:(NSString *)fromKey
{
    CGFloat result;
    CGFloat conversionTo = [[self.currencyRates objectForKey:toKey] floatValue];
    CGFloat conversionFrom = [[self.currencyRates objectForKey:fromKey] floatValue];

    self.currencyFromAmount = fromAmount;
    self.currencyKeyTo = toKey;
    self.currencyKeyFrom = fromKey;
    
    result = fromAmount * conversionTo / conversionFrom;
    self.currencyToAmount = result;
    
    return result;
}

- (CGFloat)convertStoredData
{
    self.currencyToAmount = [self convertTo:self.currencyKeyTo fromAmount:self.currencyFromAmount fromKey:self.currencyKeyFrom];
    return self.currencyToAmount;
}

@end
