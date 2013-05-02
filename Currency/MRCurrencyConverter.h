//
//  MRCurrencyConverter.h
//  Currency
//
//  Created by Matt Robinson on 4/4/13.
//  Copyright (c) 2013 Matt Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRCurrencyConverter : NSObject <NSXMLParserDelegate>
@property (strong, nonatomic, readonly) NSMutableDictionary *currencyRates;
@property (strong, nonatomic, readonly) NSString *dataRetrieved;

@property (nonatomic) CGFloat currencyToAmount;
@property (nonatomic) CGFloat currencyFromAmount;
@property (strong, nonatomic) NSString *currencyKeyTo;
@property (strong, nonatomic) NSString *currencyKeyFrom;

- (void)updateCurrencyRates:(void (^)(NSDictionary*))block;
- (CGFloat)convertStoredData;

@end
