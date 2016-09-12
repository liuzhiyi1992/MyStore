//
//  EditImageListCell.m
//  Sport
//
//  Created by haodong  on 14-5-7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "EditImageListCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

@interface EditImageListCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSArray *imageUrlList;
@end

@implementation EditImageListCell

+ (NSString*)getCellIdentifier
{
    return @"EditImageListCell";
}

+ (CGFloat)getCellHeight
{
    return 103;
}

#define TAG_BUTTON_START 10
- (void)updateCellWith:(NSString *)title
          imageUrlList:(NSArray *)imageUrlList
             indexPath:(NSIndexPath *)indexPath
                isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    self.titleLabel.text = title;
    self.imageUrlList = imageUrlList;
    
    for (int i = 0 ; i < 6 ; i ++) {
        UIButton *button = (UIButton *)[self.contentView viewWithTag:TAG_BUTTON_START + i];
        
        if (i <= [imageUrlList count]) {
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, button.frame.size.width, button.frame.size.height)];
            [imageView setClipsToBounds:YES];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            
            for (UIView *view in button.subviews) {
                if ([view isKindOfClass:[UIImageView class]])
                {
                    [view removeFromSuperview];
                }
            }
            
            if (i < [imageUrlList count]) {
                NSString *str = [imageUrlList objectAtIndex:i];
                [imageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[SportImage placeHolderImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                    if (image == nil) {
//                        [imageView setImage:[SportImage placeHolderImage]];
//                    }
                }];

                [button addSubview:imageView];
               // [button sd_setBackgroundImageWithURL:[NSURL URLWithString:str] forState:UIControlStateNormal];
                button.hidden = NO;
                
            }else {
                [imageView setImage:[SportImage addImageButtonImage]];
                [button addSubview:imageView];
                //[button setBackgroundImage:[SportImage addImageButtonImage] forState:UIControlStateNormal];
                button.hidden = NO;
            }
        }
        else{
            button.hidden = YES;
            for (UIView *view in button.subviews) {
                if ([view isKindOfClass:[UIImageView class]])
                {
                    [view removeFromSuperview];
                }
            }
        }
    }
    
    UIImage *image = nil;
    if (indexPath.row == 0 && isLast) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    UIImageView *bv = [[UIImageView alloc] initWithImage:image];
    [self setBackgroundView:bv];
}

- (IBAction)clickImageButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag - TAG_BUTTON_START;
    if (index == [_imageUrlList count]) {
        if ([_delegate respondsToSelector:@selector(didClickEditImageListCellAddButton:)]) {
            [_delegate didClickEditImageListCellAddButton:_indexPath];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(didClickEditImageListCellImage:imageIndex:)]) {
            [_delegate didClickEditImageListCellImage:_indexPath imageIndex:index];
        }
    }
}

@end
