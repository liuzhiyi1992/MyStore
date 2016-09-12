//
//  CourtJoinOrderInfoView.m
//  Sport
//
//  Created by lzy on 16/6/16.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailCourtJoinInfoView.h"
#import "Order.h"
#import "OrderDetailCourtJoinParticipatorView.h"
#import "UIColor+hexColor.h"
#import "UIView+Utils.h"
#import "CourtJoinBriefEditingView.h"
#import "CourtJoinDetailController.h"

int const PARTICIPATOR_INITIAL_DISPLAY_NUM = 3;
int const PARTICIPATOR_VIEW_HEIGHT = 70;
int const TAG_PARTICIPATOR_VIEW = 20160616;

@interface OrderDetailCourtJoinInfoView() <CourtJoinBriefEditingViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *numOfPeopleView;
@property (weak, nonatomic) IBOutlet UILabel *remainingMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefLabel;
@property (weak, nonatomic) IBOutlet UIButton *editDescButon;
@property (weak, nonatomic) IBOutlet UIImageView *editDescButtonImageView;

@property (strong, nonatomic) UIButton *spreadButton;
@property (weak, nonatomic) IBOutlet UIView *courtJoinBriefView;
@property (strong, nonatomic) NSMutableArray *activeParticipatorView;
@property (assign, nonatomic) BOOL isSpread;
@property (strong, nonatomic) Order *order;
@end

@implementation OrderDetailCourtJoinInfoView

+ (OrderDetailCourtJoinInfoView *)createViewWithOrder:(Order *)order delegate:(id<OrderDetailCourtJoinInfoViewDelegate>)delegate {
    OrderDetailCourtJoinInfoView *view = [[NSBundle mainBundle] loadNibNamed:@"OrderDetailCourtJoinInfoView" owner:nil options:nil][0];
    view.delegate = delegate;
    view.order = order;
    [view configureViewWithOrder:order];
    return view;
}

- (NSMutableArray *)activeParticipatorView {
    if (_activeParticipatorView == nil) {
        _activeParticipatorView = [NSMutableArray array];
    }
    return _activeParticipatorView;
}

- (void)configureViewWithOrder:(Order *)order {
    //desc
    _briefLabel.text = order.courtJoin.joinDescription.length > 0 ? order.courtJoin.joinDescription : COURTJOIN_DESC_LABEL_DEFAULT_CONTENT;
    if (order.courtJoin.status == JoinStatusDone || order.courtJoin.status == JoinStatusRefund) {
        [_editDescButon removeFromSuperview];
        [_editDescButtonImageView removeFromSuperview];
    }
    
    //status
    _statusLabel.text = order.courtJoin.statusMsg;
    
    //leftJoinNumber
    _remainingMsgLabel.text = order.courtJoin.leftJoinNumberMsg;
    
    //clear participatorView
    if (_activeParticipatorView != nil) {
        for (UIView *view in _activeParticipatorView) {
            [view removeFromSuperview];
        }
    }
    [_spreadButton removeFromSuperview];
    
    NSArray *participatorList = order.courtJoin.userList;
    
    if (participatorList.count > 0) {
        //有成员
        NSMutableDictionary *views = [NSMutableDictionary dictionaryWithObject:_courtJoinBriefView forKey:@"courtJoinBriefView"];
        [views setObject:_titleLabel forKey:@"titleLabel"];
        [views setObject:_numOfPeopleView forKey:@"numOfPeopleView"];
        NSMutableString *vConstraintString = [NSMutableString string];
        [vConstraintString appendString:@"V:[courtJoinBriefView]"];
        for (int i = 0; i < participatorList.count; i++) {
            if (i >= PARTICIPATOR_INITIAL_DISPLAY_NUM && _isSpread == NO) {
                break;
            }
            OrderDetailCourtJoinParticipatorView *participatorView = [OrderDetailCourtJoinParticipatorView createViewWithCourtJoinUser:participatorList[i]];
            [self.activeParticipatorView addObject:participatorView];
            [views setObject:participatorView forKey:[NSString stringWithFormat:@"participatorView%d", i]];
            [participatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [self addSubview:participatorView];
            
            //hConstraint
            NSString *hConstraintString = [NSString stringWithFormat:@"H:|[participatorView%d]|", i];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hConstraintString options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
            //vConstraint
            if (i+1 < PARTICIPATOR_INITIAL_DISPLAY_NUM && i+1 < participatorList.count) {
                [vConstraintString appendString:[NSString stringWithFormat:@"[participatorView%d(%d)]", i, PARTICIPATOR_VIEW_HEIGHT]];
            } else {
                //最后一个
                [vConstraintString appendString:[NSString stringWithFormat:@"[participatorView%d(%d)]", i, PARTICIPATOR_VIEW_HEIGHT]];
            }
        }
        
        //spreadButton
        NSString *vTailConstraintString = @"|";
        if (participatorList.count > PARTICIPATOR_INITIAL_DISPLAY_NUM) {
            if (_spreadButton == nil) {
                self.spreadButton = [[UIButton alloc] init];
                [_spreadButton setTitle:@"查看所有加入者" forState:UIControlStateNormal];
                [[_spreadButton titleLabel] setFont:[UIFont systemFontOfSize:10]];
                [_spreadButton setTitleColor:[UIColor hexColor:@"666666"] forState:UIControlStateNormal];
                UIImage *buttonImage = [UIImage imageNamed:@"arrow_down_black.png"];
                [_spreadButton setImage:buttonImage forState:UIControlStateNormal];
                _spreadButton.imageEdgeInsets = UIEdgeInsetsMake(0, 85, 0, 0);
                _spreadButton.titleEdgeInsets = UIEdgeInsetsMake(0, -buttonImage.size.width, 0, buttonImage.size.width);;
                [_spreadButton addTarget:self action:@selector(spreadMoreParticipator:) forControlEvents:UIControlEventTouchUpInside];
                [_spreadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            }
            [views setObject:_spreadButton forKey:@"spreadButton"];
            [self addSubview:_spreadButton];
            
            vTailConstraintString = @"-9-[spreadButton]-9-|";
            NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_spreadButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100.f];
            [self addConstraint:widthConstraint];
        }
        
        [vConstraintString appendString:vTailConstraintString];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vConstraintString options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    }
    [self fitHeight];
}

- (void)fitHeight {
    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [self updateHeight:size.height];
    if (self.superview != nil && [_delegate respondsToSelector:@selector(orderDetailCourtJoinInfoViewDidChangeHeight:)]) {
        [_delegate orderDetailCourtJoinInfoViewDidChangeHeight:size.height];
    }
}

- (void)spreadMoreParticipator:(UIButton *)sender {
    CGFloat futureAngle = 0;
    if (_isSpread == NO) {
        futureAngle = M_PI;
    } else {
        futureAngle = 0;
    }
    [sender.imageView setTransform:CGAffineTransformMakeRotation(futureAngle)];
    self.isSpread = !_isSpread;
    [self configureViewWithOrder:_order];
}

- (IBAction)clickCourtJoinDetailsButton:(id)sender {
    CourtJoinDetailController *controller = [[CourtJoinDetailController alloc] initWithCourtJoinId:_order.orderId];
    UIViewController *sponsorController = nil;
    [self findControllerWithResultController:&sponsorController];
    if (sponsorController != nil) {
        [sponsorController.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)clickEditBriefButton:(id)sender {
    CourtJoinBriefEditingView *view = [CourtJoinBriefEditingView createView:self order:_order courtJoinDesc:_briefLabel.text];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:view];
}

- (void)briefEditingViewDidSubmitWithDesc:(NSString *)desc {
    _briefLabel.text = desc.length > 0 ? desc : COURTJOIN_DESC_LABEL_DEFAULT_CONTENT;
}

@end
