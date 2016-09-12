//
//  CoachHomeController.m
//  Sport
//
//  Created by liuzhiyi on 15/8/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachHomeController.h"
#import "CoachBriefCell.h"
@interface CoachHomeController ()

@end

@implementation CoachHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)clickHeaderViewLeftButton:(UIButton *)sender {
    
    CGPoint buttonPoint = sender.center;
    CGPoint slideBarPoint = self.slideBar.center;
    
    slideBarPoint.x = buttonPoint.x;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.slideBar.center = slideBarPoint;
    }];
    
    
}


- (IBAction)clickHeaderViewRightButton:(UIButton *)sender {
    
    CGPoint buttonPoint = sender.center;
    CGPoint slideBarPoint = self.slideBar.center;
    
    slideBarPoint.x = buttonPoint.x;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.slideBar.center = slideBarPoint;
    }];
}





#pragma mark - tableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    NSString *identifier = [CoachBriefCell getCellIdentifier];
    CoachBriefCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    if(cell == nil) {
        cell = [CoachBriefCell createCell];
    }
    
    [cell initLayout];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CoachBriefCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
