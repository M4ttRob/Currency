//
//  MRPickerView.m
//  Currency
//
//  Created by Matt Robinson on 4/5/13.
//  Copyright (c) 2013 Matt Robinson. All rights reserved.
//

#import "MRPickerView.h"

@implementation MRPickerView

- (MRPickerView *)init
{
    self = [super init];
    return self;
}

- (MRPickerView *)initWithImage:(UIImage *)image withText:(NSString *)text
{
    self = [self init];
    
    if (self) {
        UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 22-(10/2), 19, 10)];
        flagView.image = image;
        UILabel *keyView = [[UILabel alloc] initWithFrame:CGRectMake(30+19+30, 0, 50, 44)];
        keyView.text = text;
        
        keyView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        
        self.flagImage = flagView;
        self.flagText = keyView;
        
        [self addSubview:self.flagImage];
        [self addSubview:self.flagText];
    }

    return self;
}

@end
