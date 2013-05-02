//
//  MRPickerView.h
//  Currency
//
//  Created by Matt Robinson on 4/5/13.
//  Copyright (c) 2013 Matt Robinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRPickerView : UIView

@property (strong, nonatomic) UIImageView *flagImage;
@property (strong, nonatomic) UILabel *flagText;

- (MRPickerView *)initWithImage:(UIImage *)image withText:(NSString *)text;

@end
