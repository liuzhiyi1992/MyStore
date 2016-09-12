//
//  AMapSearchAddressView.m
//  Sport
//
//  Created by 江彦聪 on 15/10/13.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "AMapSearchAddressView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "UITableView+Utils.h"
#import "AMapSearchAddressCell.h"

@interface AMapSearchAddressView()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet UIView *noDataView;

@end


@implementation AMapSearchAddressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib {
    [super awakeFromNib];
    self.dataList = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.noDataView.hidden = YES;
    [self.tableView sizeHeaderToFit:0];
    self.tableViewHeightConstrant.constant = 0;
}

+ (AMapSearchAddressView *)createAMapSearchAddressView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AMapSearchAddressView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    AMapSearchAddressView *view = [topLevelObjects objectAtIndex:0];
    
    UINib *cellNib = [UINib nibWithNibName:[AMapSearchAddressCell getCellIdentifier] bundle:nil];
    [view.tableView registerNib:cellNib forCellReuseIdentifier:[AMapSearchAddressCell getCellIdentifier]];
    return view;
}

-(void)showWithFrame:(CGRect)frame {

    [self setFrame:frame];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
}

-(void)refreshDataList:(NSMutableArray *)array
                height:(CGFloat)height {
    self.dataList = array;
    
    [self refreshHeight:height];
}

-(void) refreshHeight:(CGFloat)height {
    
    if ([self.dataList count] == 0) {
        self.noDataView.hidden = NO;
        [self.tableView sizeHeaderToFit:110];
        self.tableViewHeightConstrant.constant = 110;
    } else {
        self.noDataView.hidden = YES;
        [self.tableView sizeHeaderToFit:0];
        CGFloat dataHeight =  60*[_dataList count];
        self.tableViewHeightConstrant.constant = dataHeight > height?height:dataHeight;
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    AMapSearchAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:[AMapSearchAddressCell getCellIdentifier]];

    AMapTip *tips = [self.dataList objectAtIndex:indexPath.row];
    
    if ([tips isKindOfClass:[AMapTip class]]) {
        cell.titleLabel.text = tips.name;
        cell.subTitleLabel.text = tips.district;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(didClickAddress:)]) {
        AMapTip *tips = [self.dataList objectAtIndex:indexPath.row];
        if ([tips isKindOfClass:[AMapTip class]]) {
            [_delegate didClickAddress:tips.name];
        }
    }
}
- (IBAction)clickBackground:(id)sender {
    if ([_delegate respondsToSelector:@selector(didCancelInput)]) {
        [_delegate didCancelInput];
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(didScrollTableView)]) {
        [_delegate didScrollTableView];
    }
}

@end
