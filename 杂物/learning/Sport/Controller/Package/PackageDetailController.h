//
//  PackageDetailController.h
//  Sport
//
//  Created by haodong  on 14/12/1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "PackageService.h"

@class Package;

@interface PackageDetailController : SportController <PackageServiceDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
//@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

- (instancetype)initWithPackage:(Package *)package isSpecialSale:(BOOL)isSpecialSale;

- (instancetype)initWithPackageId:(NSString *)packageId isSpecialSale:(BOOL)isSpecialSale;

@end