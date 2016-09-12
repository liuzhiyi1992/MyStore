//
//  EditGenderController.m
//  Sport
//
//  Created by haodong  on 13-7-16.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "EditGenderController.h"
#import "UserManager.h"
#import "UserService.h"

@interface EditGenderController ()
@property (strong, nonatomic) NSArray *dataList;
@property (copy, nonatomic) NSString *gender;
@end

@implementation EditGenderController

- (void)viewDidUnload {
    [self setDataTableView:nil];
    [super viewDidUnload];
}

- (instancetype)initWithGender:(NSString *)gender
{
    self = [super init];
    if (self) {
        self.gender = gender;
    }
    return self;
}

#define TITLE_MAN       DDTF(@"kMan")
#define TITLE_FEMALE    DDTF(@"kFemale")
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kGender");
    self.view.backgroundColor = [SportColor defaultPageBackgroundColor];
    self.dataList = [NSArray arrayWithObjects:TITLE_MAN, TITLE_FEMALE, nil];
}

#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [EditGenderCell getCellIdentifier];
    EditGenderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [EditGenderCell createCell];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    NSString *cellTitle = [_dataList objectAtIndex:indexPath.row];
    
    BOOL isSelected = NO;
    
    if ([cellTitle isEqualToString:TITLE_MAN]
        && [_gender isEqualToString:GENDER_MALE]) {
        isSelected = YES;
    }
    if ([cellTitle isEqualToString:TITLE_FEMALE]
        && [_gender isEqualToString:GENDER_FEMALE]) {
        isSelected = YES;
    }
    
    [cell updateCell:cellTitle isSelected:isSelected indexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EditGenderCell getCellHeight];
}

- (void)didClickEditGenderCell:(NSIndexPath *)indexPath
{
    NSString *cellTitle = [_dataList objectAtIndex:indexPath.row];
    NSString *gender = nil;
    if ([cellTitle isEqualToString:TITLE_MAN]) {
        gender = GENDER_MALE;
    }
    if ([cellTitle isEqualToString:TITLE_FEMALE]) {
        gender = GENDER_FEMALE;
    }
    
    if ([_delegate respondsToSelector:@selector(didSelectGender:)]) {
        [_delegate didSelectGender:gender];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
