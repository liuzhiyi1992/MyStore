//
//  VenuesSelectView.m
//  Sport
//
//  Created by lzy on 16/6/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "VenuesSelectView.h"
#import "UIColor+hexColor.h"
#import "UIVIew+Utils.h"
#import <objc/runtime.h>

const char kVenuesId;
const int SELECT_BUTTON_HEIGHT = 30;

@interface VenuesSelectView()
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation VenuesSelectView

+ (VenuesSelectView *)showViewWithVenuesNameArray:(NSArray *)array
                                         delegate:(id<VenuesSelectViewDelegate>)delegate {
    VenuesSelectView *view = [[NSBundle mainBundle] loadNibNamed:@"VenuesSelectView" owner:nil options:nil][0];
    view.delegate = delegate;
    [view configureSelectButtonWithVenuesArray:array];
    [view show];
    return view;
}

- (void)configureSelectButtonWithVenuesArray:(NSArray *)array {
    NSMutableString *vConstraintString = [NSMutableString string];
    [vConstraintString appendString:@"V:[subTitleLabel]-25-"];
    NSMutableDictionary *views = [NSMutableDictionary dictionaryWithObject:_subTitleLabel forKey:@"subTitleLabel"];
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [self createVenuesItemButtonWithTitle:array[i]];
        NSString *venuesId = objc_getAssociatedObject(array[i], &kVenuesId);
        objc_setAssociatedObject(button, &kVenuesId, venuesId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [button addTarget:self action:@selector(clickVenuesButton:) forControlEvents:UIControlEventTouchUpInside];
        [views setObject:button forKey:[NSString stringWithFormat:@"button%d", i]];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:button];
        NSString *hConstraintString = [NSString stringWithFormat:@"H:|-35-[button%d]-35-|", i];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hConstraintString options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        //vConstraint
        if (i+1 != array.count) {
            [vConstraintString appendString:[NSString stringWithFormat:@"[button%d(%d)]-12-", i, SELECT_BUTTON_HEIGHT]];
        } else {
            [vConstraintString appendString:[NSString stringWithFormat:@"[button%d(%d)]", i, SELECT_BUTTON_HEIGHT]];
        }
    }
    [vConstraintString appendString:@"-25-|"];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vConstraintString options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    [self fitHeight];
}

- (UIButton *)createVenuesItemButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    [button.titleLabel setMinimumScaleFactor:0.8];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor hexColor:@"222222"] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [UIColor hexColor:@"222222"].CGColor;
    button.layer.cornerRadius = SELECT_BUTTON_HEIGHT/2;
    return button;
}

- (void)show {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat scale = 0.7;
    if (screenHeight <= 568) {//i4, i5
        scale = 0.85;
    }
    [self updateWidth:keyWindow.bounds.size.width * scale];
    [self updateCenterY:keyWindow.center.y];
    [self updateCenterX:keyWindow.center.x];
    [keyWindow addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)fitHeight {
    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [self updateHeight:size.height];
}

- (void)clickVenuesButton:(UIButton *)button {
    NSString *venuesId = objc_getAssociatedObject(button, &kVenuesId);
    [_delegate venuesSelectViewDidSelectedVenuesId:venuesId];
}

@end
