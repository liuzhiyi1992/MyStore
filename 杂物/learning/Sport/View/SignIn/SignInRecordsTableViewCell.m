//
//  SignInRecordsTableViewCell.m
//  Sport
//
//  Created by lzy on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SignInRecordsTableViewCell.h"
#import "SignInRecordsContentView.h"
#import "SportSignInWriteRecordController.h"
#import "UIView+Utils.h"

const int TAG_DIARY_CONTENT_VIEW = 20160623;

@interface SignInRecordsTableViewCell()

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *scaleFitConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *writingButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *writeDiaryButton;
@property (strong, nonatomic) SignInRecordsContentView *diaryContentView;
@property (copy, nonatomic) NSString *signInId;
@property (copy, nonatomic) NSString *coterieId;
@property (copy, nonatomic) NSString *coterieName;

@end

@implementation SignInRecordsTableViewCell


+ (id)createCell {
    SignInRecordsTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SignInRecordsTableViewCell" owner:self options:nil][0];
    [cell configureCell];
    return cell;
}

- (void)awakeFromNib {
    [self configureCell];
}

- (void)configureCell {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat scale = 1;
    if (screenHeight == 480) {//i4
        scale = 0.6;
    } else if (screenHeight == 568) {//i5
        scale = 0.6;
    }
    
    for (NSLayoutConstraint *constraint in _scaleFitConstraints) {
        constraint.constant = scale * constraint.constant;
    }
}

- (void)updateCellWithDataDict:(NSDictionary *)dataDict {
    self.signInId = [dataDict validStringValueForKey:PARA_SIGN_IN_ID];
    NSDictionary *coterieDict = [dataDict validDictionaryValueForKey:PARA_COTERIE];
    self.coterieId = [coterieDict validStringValueForKey:PARA_COTERIE_ID];
    self.coterieName = [coterieDict validStringValueForKey:PARA_COTERIE_NAME];
    _dateLabel.text = [dataDict validStringValueForKey:PARA_SIGN_IN_TIME];
    _venuesNameLabel.text = [dataDict validStringValueForKey:PARA_VENUES_NAME];
    
    NSString *diaryStatus = [dataDict validStringValueForKey:PARA_STATUS];
    if ([diaryStatus isEqualToString:@"1"]) {
        //已写日记
        NSString *content = [dataDict validStringValueForKey:PARA_CONTENT];
        NSArray *galleryArray = [dataDict validArrayValueForKey:PARA_GALLERY];
        [self configureContnetViewWithContent:content imageArray:galleryArray];
        _writeDiaryButton.hidden = YES;
//        _writingButtonLeadingConstraint.active = NO;
    } else {
        //未写日记
        _writeDiaryButton.hidden = NO;
        if (_diaryContentView) {
            [_diaryContentView removeFromSuperview];
        }
    }
}

- (void)configureContnetViewWithContent:(NSString *)content imageArray:(NSArray *)imageArray {
    UIView *previousView = [self viewWithTag:TAG_DIARY_CONTENT_VIEW];
    if (previousView) {
        [previousView removeFromSuperview];
    }
    self.diaryContentView = [SignInRecordsContentView createViewWithContent:content imageArray:imageArray];
    _diaryContentView.tag = TAG_DIARY_CONTENT_VIEW;
    [_diaryContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:_diaryContentView];
    
    NSDictionary *views = @{@"venuesNameLabel":_venuesNameLabel, @"diaryContentView":_diaryContentView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[venuesNameLabel]-15-[diaryContentView]-20-|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[diaryContentView]-15-|" options:0 metrics:nil views:views]];
    
    [_diaryContentView calculateContentLabelheight];
}

- (IBAction)clickWriteDiaryButton:(id)sender {
    //写日志
    UIViewController *sponsorController = nil;
    [self findControllerWithResultController:&sponsorController];
    if (nil != sponsorController) {
        SportSignInWriteRecordController *controller = [[SportSignInWriteRecordController alloc] initWithSignInId:_signInId forumId:self.coterieId forumName:self.coterieName];
        [sponsorController.navigationController pushViewController:controller animated:YES];
    }
}

@end
