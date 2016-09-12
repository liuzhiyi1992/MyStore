//
//  EditGenderController.h
//  Sport
//
//  Created by haodong  on 13-7-16.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "EditGenderCell.h"

@protocol EditGenderControllerDelegate <NSObject>
@optional
- (void)didSelectGender:(NSString *)gender;
@end

@interface EditGenderController : SportController<UITableViewDelegate, UITableViewDataSource, EditGenderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (assign, nonatomic) id<EditGenderControllerDelegate> delegate;

- (instancetype)initWithGender:(NSString *)gender;

@end
