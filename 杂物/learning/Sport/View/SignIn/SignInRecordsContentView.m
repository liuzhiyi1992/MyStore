//
//  SignInRecordsContentView.m
//  Sport
//
//  Created by lzy on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SignInRecordsContentView.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"
#import "NSString+Utils.h"
#import "UILabel+Utils.h"
#import "SportMWPhotoBrowser.h"

int const TAG_BASE_RADIX = 11;

@interface SignInRecordsContentView()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *imageHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstraint;
@property (strong, nonatomic) NSArray *imageArray;

@end

@implementation SignInRecordsContentView

+ (SignInRecordsContentView *)createViewWithContent:(NSString *)content imageArray:(NSArray *)imageArray {
    SignInRecordsContentView *view = [[NSBundle mainBundle] loadNibNamed:@"SignInRecordsContentView" owner:self options:nil][0];
    [view configureViewWithContent:content imageArray:imageArray];
    return view;
}

- (void)configureViewWithContent:(NSString *)content imageArray:(NSArray *)imageArray {
    self.imageArray = imageArray;
    //内容
    _contentLabel.text = content;
    
    //图片
    if (imageArray.count != 0) {
        for (int i = 0; i < 9; i++) {
            UIImageView *imageView = [_imageHolderView viewWithTag:TAG_BASE_RADIX + i];
            if (i >= imageArray.count) {
                [imageView removeFromSuperview];
            } else {
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreemDisplayImage:)];
                [imageView addGestureRecognizer:tapGesture];
                [imageView setUserInteractionEnabled:YES];
                NSString *imageUrlString = imageArray[i];
                if (imageUrlString != nil && imageUrlString.length > 0) {
                    //合法
                    NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
                    [imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_image_sq"]];
                }
            }
        }
    } else {
        //无图
        [_imageHolderView removeFromSuperview];
    }
}

- (void)fullScreemDisplayImage:(UITapGestureRecognizer *)tapGesture {
    UIImageView *imageView = (UIImageView *)tapGesture.view;
    NSMutableArray *mwPhotoList = [NSMutableArray array];
    int i = 0;
    for (NSString *imageUrlString in _imageArray) {
        SportMWPhoto *mwPhoto = [SportMWPhoto photoWithURL:[NSURL URLWithString:imageUrlString]];
        mwPhoto.index = i++;
        [mwPhotoList addObject:mwPhoto];
    }
    int imageIndex = (int)(imageView.tag - TAG_BASE_RADIX);
    SportMWPhotoBrowser *controller = [[SportMWPhotoBrowser alloc]initWithPhotoList:mwPhotoList openIndex:imageIndex];
    
    UIViewController *sponsorController = nil;
    [self findControllerWithResultController:&sponsorController];
    if (sponsorController) {
        [sponsorController.navigationController pushViewController:controller animated:YES];
    }
}

- (void)calculateContentLabelheight {
    if (_contentLabel.text.length == 0) {
        _contentLabelHeightConstraint.constant = 0;
    } else {
        CGSize size = [_contentLabel.text sizeWithMyFont:_contentLabel.font constrainedToSize:CGSizeMake(_contentLabel.frame.size.width, CGFLOAT_MAX)];
        _contentLabelHeightConstraint.constant = size.height;
    }
}

@end
