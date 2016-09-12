//
//  CoachPickerView.m
//  Sport
//
//  Created by 江彦聪 on 15/9/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachPickerView.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"
#import "CoachBookingInfo.h"

@interface CoachPickerView()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeightConstraint;

@property (assign, nonatomic) NSUInteger interval; //分钟
//@property (strong, nonatomic) NSMutableArray *dateTimeArray;

@end

@implementation CoachPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


//+ (NSString *)viewIdentifier {
//    static NSString* _viewIdentifier = @"CoachPickerView";
//    _viewIdentifier = NSStringFromClass([self class]);
//    return _viewIdentifier;
//}
//
//- (instancetype)initWithCoder:(NSCoder *)aDecoder{
//    self = [super initWithCoder:aDecoder];
//    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SportPickerView" owner:self options:nil];
//    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
//        return nil;
//    }
//    
//    [self addSubview: [topLevelObjects objectAtIndex:0]];
//    return self;
//}

+ (CoachPickerView *)createCoachPickerView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachPickerView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    CoachPickerView *view = [topLevelObjects objectAtIndex:0];
    view.lineViewHeightConstraint.constant = 0.5;

    return view;
}


//- (id)init
//{
//    // NOTE: If you don't know the size, you can work this out after you load the nib.
//    self = [super initWithFrame:CGRectMake(0, 0, 320, 480)];
//    if (self) {
//        // Load the nib using the instance as the owner.
//        NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"SportPickerView" owner:self options:nil];
//        [self addSubview:[xib objectAtIndex:0]];
//    }
//    return self;
//}

//+ (instancetype)createCoachPickerView
//{
//    return [[self alloc] init];
//}

#define MORNING_INTERVAL 12*ONE_HOUR_INTERVAL
#define AFTERNOON_INTERVAL 18*ONE_HOUR_INTERVAL
- (void)show {
    
    [super show];

}


-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    switch (component) {
        case 0:
            return width*3/5;
        default:
            return width*2/5;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [self.dataList count];
    } else {
        NSUInteger selectRow = [self.dataPickerView selectedRowInComponent:0];
        return [self.dataList[selectRow][1] count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
//        CoachBookingInfo *info = [self.dateTimeArray[row][0];
//        if (![info isKindOfClass:[CoachBookingInfo class]]) {
//            return nil;
//        }
        NSDate *date = self.dataList[row][0];
        if (![date isKindOfClass:[NSDate class]]) {
            return nil;
        }
        
        NSString *title = [DateUtil dateStringWithWeekday:date];
        return title;
    } else {
        NSUInteger dateRow = [self.dataPickerView selectedRowInComponent:0];
        NSArray *stringArray = self.dataList[dateRow][1];
        
        NSString *title = nil;
        if ([stringArray isKindOfClass:[NSArray class]] && [stringArray count] > row) {
            title = stringArray[row];
        }
        
        return title;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
}

- (IBAction)clickOKButton:(id)sender {
    NSInteger selectRow = [self.dataPickerView selectedRowInComponent:0];
    
    if ([self.delegate respondsToSelector:@selector(didClickSportPickerViewOKButton:row:)]) {
        [self.delegate didClickSportPickerViewOKButton:self row:selectRow];
    }
    [self removeFromSuperview];
}

+ (NSArray *)generateDayTimeStringWithBegin:(NSDate *)beginTime
                                  end:(NSDate *)endTime
                                  interval:(NSUInteger)interval {
    NSMutableArray *resultArray = [NSMutableArray array];
    
    while ([beginTime isEarlierThanDate:endTime]) {
        NSDate *tempDate = [beginTime dateByAddingMinutes:interval];
        [resultArray addObject:[DateUtil stringFromDate:tempDate DateFormat:@"HH:mm"]];
        beginTime = tempDate;
    }
    
    return resultArray;
}
@end
