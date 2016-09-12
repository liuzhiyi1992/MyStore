//
//  SportPickerController.h
//  
//
//  Created by 江彦聪 on 15/9/15.
//
//

#import "SportController.h"

@protocol SportPickerControllerDelegate <NSObject>
@optional
- (void)didClickSportPickerViewOKButton:(UIPickerView *)sportPickerView
                                    row:(NSInteger)row;
@end

@interface SportPickerController : SportController<UIPickerViewDataSource, UIPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UIPickerView *dataPickerView;
@property (weak, nonatomic) IBOutlet UIView *pickerHolderView;

@property (strong, nonatomic) NSArray *dataList;

@property (assign, nonatomic) id<SportPickerControllerDelegate> delegate;
@end
