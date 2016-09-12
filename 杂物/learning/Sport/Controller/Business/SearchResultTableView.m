//
//  SearchResultTableView.m
//  Sport
//
//  Created by 冯俊霖 on 15/11/4.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "SearchResultTableView.h"
#import "ForumSearchResultCell.h"
#import "NSDictionary+JsonValidValue.h"
#import "NSString+Utils.h"
#import "BusinessSearchDataManager.h"

@interface SearchResultTableView()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) NSArray *sourceDataList;
@property (strong, nonatomic) NSMutableArray *showDataArray;
@property (strong, nonatomic) NSMutableArray *numberMateArray;
@property (copy, nonatomic) NSString *searchText;

@property (assign, nonatomic) int matchCount;
@property (assign, nonatomic) int matchFirst;
@end

@implementation SearchResultTableView
- (NSArray *)dataList{
    if (_dataList == nil) {
        _dataList = [NSArray array];
    }
    return _dataList;
}

- (NSArray *)sourceDataList{
    if (_sourceDataList == nil) {
        _sourceDataList = [NSArray array];
    }
    return _sourceDataList;
}

- (NSMutableArray *)showDataArray{
    if (_showDataArray == nil) {
        _showDataArray = [NSMutableArray array];
    }
    return _showDataArray;
}

- (NSMutableArray *)numberMateArray{
    if (_numberMateArray == nil) {
        _numberMateArray = [NSMutableArray array];
    }
    return _numberMateArray;
}

+ (SearchResultTableView *)createSearchResultTableView{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchResultTableView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    SearchResultTableView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = view;
    view.dataSource = view;
    [view setFrame:CGRectMake(0, 114, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 114)];
    [view setSeparatorStyle:NO];
    view.sourceDataList = [[BusinessSearchDataManager defaultManager] analysisSourceData];
    [view matchingNumberMateArray];
    return view;
}

- (void)matchingNumberMateArray{
    NSArray *firstArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20", nil];
    NSArray *secondArray = [NSArray arrayWithObjects:@"零",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十", nil];
    NSArray *thirdArray = [NSArray arrayWithObjects:@"零",@"壹",@"贰",@"叁",@"肆",@"伍",@"陆",@"柒",@"捌",@"玖",@"拾",@"拾壹",@"拾贰",@"拾叁",@"拾肆",@"拾伍",@"拾陆",@"拾柒",@"拾捌",@"拾玖",@"贰拾", nil];
    self.numberMateArray = [NSMutableArray arrayWithObjects:secondArray,firstArray,thirdArray, nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [ForumSearchResultCell getCellIdentifier];
    ForumSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [ForumSearchResultCell createCell];
    }
    BOOL isLast = NO;
    NSString *forum = [self.dataList objectAtIndex:indexPath.row];
    isLast = (indexPath.row == ([self.dataList count] - 1));
        
    [cell updateCellWith:forum
                    city:nil
                indexPath:indexPath
                    isLast:isLast];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MobClickUtils event:umeng_event_click_recommended_key_word];
    NSString *clickOne = [self.dataList objectAtIndex:indexPath.row];
    if ([_searchDelegate respondsToSelector:@selector(didSelectedTableViewCellWithWord:)]) {
        [_searchDelegate didSelectedTableViewCellWithWord:clickOne];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**
 *  根据传入的text查找数据源并更新tableView
 *
 */
- (void)reloadSearchResultTableViewWithText:(NSString *)text{
    self.searchText = text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self search];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *testArray = [self arrayWithMemberIsOnly:self.showDataArray];
            self.dataList = testArray;
            [self reloadData];
        });
    });
}

- (void)search{
    NSString *tempText = [self.searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([tempText length] == 0) {
        [self.showDataArray removeAllObjects];
        return;
    }
    
    char tempChar = [tempText characterAtIndex:0];
    NSString *text = nil;
    if ((tempChar >= 'a' && tempChar <= 'z')
        || (tempChar >= 'A' && tempChar <= 'B')) {
        text = [tempText lowercaseString];//拼音大写转小写
    } else {
        text = tempText;
    }
    
    NSMutableArray *matchArray = [NSMutableArray array];
    
    //对0到20得数字进行再次匹配
    if ([self isContainMatchWithString:text]) {
        if (self.matchCount) {
            for (int i = 0; i < self.numberMateArray.count; i++) {
                if (i == self.matchFirst) {
                    [matchArray insertObject:self.numberMateArray[i][self.matchCount] atIndex:0];
                }else{
                    [matchArray addObject:self.numberMateArray[i][self.matchCount]];
                }
            }
        }
    }else{
        //分解成单个字符串
        for (int i = 0; i < text.length; i++) {
            NSString *singleStr = [text substringWithRange:NSMakeRange(i, 1)];
            if ([self isContainMatchWithString:singleStr]) {
                if (i < text.length - 1) {
                    
                    NSString *mergeString = [singleStr stringByAppendingString:[text substringWithRange:NSMakeRange(i+1, 1)]];
                    if ([self isContainMatchWithString:mergeString]) {
                        
                        for (int j = 0; j < self.numberMateArray.count; j++) {
                            NSMutableString *muStr = [NSMutableString stringWithString:text];
                            [muStr replaceCharactersInRange:NSMakeRange(i, 2) withString:self.numberMateArray[j][self.matchCount]];
                            if (j == self.matchFirst) {
                                [matchArray insertObject:muStr atIndex:0];
                            }else{
                                [matchArray addObject:muStr];
                            }
                        }
                        
                        break;
                    } else {
                        
                        
                    }
                }
                
                for (int k = 0; k < self.numberMateArray.count; k++) {
                    NSMutableString *muStr = [NSMutableString stringWithString:text];
                    [muStr replaceCharactersInRange:NSMakeRange(i, 1) withString:self.numberMateArray[k][self.matchCount]];
                    if (k == self.matchFirst) {
                        [matchArray insertObject:muStr atIndex:0];
                    }else{
                        [matchArray addObject:muStr];
                    }
                }
            }else{
                [matchArray addObject:text];
            }
        }
    }
    
    [self.showDataArray removeAllObjects];
    
    NSArray *testArray = [self arrayWithMemberIsOnly:(NSArray *)matchArray];
    //搜索结果
    for (NSString *str in testArray) {
        text = str;
        [self.showDataArray addObjectsFromArray:[self endSearchWithText:text source:self.sourceDataList]];
    }
    
    // 将输入词放在显示结果的首行
    [self.showDataArray insertObject:self.searchText atIndex:0];
}

//判断字符串是否属于0-20匹配数组
- (BOOL)isContainMatchWithString:(NSString *)string{
    
    if ([string length] > 2) {
        return NO;
    }
    
    for (int i = 0; i < self.numberMateArray.count; i++) {
        for (int j = 0; j < [self.numberMateArray[i] count]; j++) {
            if ([string isEqualToString:self.numberMateArray[i][j]]){
                self.matchCount = j;
                self.matchFirst = i;
                
                return YES;
            }
        }
    }
    
    return NO;
}

//将数组重复的对象去除
- (NSArray *)arrayWithMemberIsOnly:(NSArray *)array
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [array count]; i++) {
        if ([categoryArray containsObject:[array objectAtIndex:i]] == NO)
        {
            [categoryArray addObject:array[i]];
        }
    }
    return categoryArray;
}

- (NSArray *)endSearchWithText:(NSString *)text
                        source:(NSArray *)sourceArray{
    
    NSMutableArray *showArray = [NSMutableArray array];
    for (NSDictionary *oneForum in sourceArray) {
        NSString *name = [oneForum validStringValueForKey:@"n"];
        NSString *quanpin = [oneForum validStringValueForKey:@"p"];
        
        BOOL nameFound = NO;
        BOOL pinyinFound = NO;
        
        if ([text validateEnglish]) {
            pinyinFound = ([quanpin rangeOfString:text].location != NSNotFound);
        }else{
            nameFound = ([name rangeOfString:text].location != NSNotFound);
        }
        if (nameFound || pinyinFound) {
            [showArray addObject:name];
        }
    }
    
    return showArray;
}
@end
