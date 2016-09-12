//
//  ShareChannelView.m
//  Sport
//
//  Created by qiuhaodong on 15/5/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ShareChannelView.h"
#import "UIView+Utils.h"


@interface ShareChannelView()
@property (weak, nonatomic) IBOutlet UIButton *iconButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (assign, nonatomic) id<ShareChannelViewDelegate> delegate;
@end

@implementation ShareChannelView

+ (CGSize)defaultSize
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, 96);
}

+ (ShareChannelView *)createViewWithImage:(UIImage *)image
                                     name:(NSString *)name
                                 delegate:(id<ShareChannelViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ShareChannelView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    ShareChannelView *view = (ShareChannelView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateWidth:[self defaultSize].width];
    [view updateHeight:[self defaultSize].height];
    [view.iconButton setImage:image forState:UIControlStateNormal];
    view.nameLabel.text = name;
    return view;
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickShareChannelView:)]) {
        [_delegate didClickShareChannelView:self];
    }
}


@end
