//
//  CharacteristicView.h
//  Sport
//
//  Created by haodong  on 13-8-25.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharacteristicView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

+ (CharacteristicView *)createCharacteristicView;

+ (CGFloat)getHeight;
+ (CGFloat)getWidth:(NSString *)value
;
- (void)updateView:(NSString *)value index:(NSUInteger)index;

@end
