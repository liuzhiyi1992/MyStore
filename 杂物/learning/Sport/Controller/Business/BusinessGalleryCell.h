//
//  BusinessGalleryCell.h
//  Sport
//
//  Created by haodong  on 14-9-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

//use businessPhoto to scroll review photo list
#import "BusinessPhoto.h"


@protocol BusinessGalleryCellDelegate <NSObject>
@optional
- (void)didClickBusinessGalleryCell:(NSUInteger)openIndex;
@end

@interface BusinessGalleryCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;

@property (assign, nonatomic) id<BusinessGalleryCellDelegate> delegate;

- (void)updateCellWithFirstPhoto:(BusinessPhoto *)firstPhoto
                     secondPhoto:(BusinessPhoto *)secondPhoto
                       indexPath:(NSIndexPath *)indexPath;

@end
