//
//  ForumSearchController.m
//  Sport
//
//  Created by haodong  on 15/5/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumSearchController.h"
#import "ForumSearchManager.h"
#import "NSDictionary+JsonValidValue.h"
#import "ForumSearchResultCell.h"
#import "ClearSearchHistoryCell.h"
#import "UIView+Utils.h"
#import "ForumDetailController.h"
#import "NSString+Utils.h"

typedef enum
{
    SearchListTypeHistory = 0,
    SearchListTypeResult = 1,
}SearchListType;


@interface ForumSearchController ()

@property (copy, nonatomic) NSString *searchText;
@property (strong, nonatomic) NSDictionary *searchSourceData;
@property (strong, nonatomic) NSMutableArray *searchResultList;
@property (strong, nonatomic) NSArray *histroyList;
@property (assign, nonatomic) SearchListType type;

@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (weak, nonatomic) IBOutlet UIView *titileView;
@property (weak, nonatomic) IBOutlet UIImageView *searchInputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end

@implementation ForumSearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.searchInputBackgroundImageView setImage:[SportImage searchBackgroundImage]];
    [self.titileView updateWidth:[UIScreen mainScreen].bounds.size.width];
    self.navigationItem.titleView = self.titileView;
    
    [self.inputTextField becomeFirstResponder];
    [self showSearchResultViewWithText:nil];
}

//不创建返回按钮
- (void)createBackButton
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero] ;
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:view] ;
    self.navigationItem.leftBarButtonItem = buttonItem;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [self.inputTextField resignFirstResponder];
        [self showSearchResultViewWithText:textField.text];
        return NO;
    } else {
        NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self showSearchResultViewWithText:aString];
        return YES;
    }
}

- (void)showSearchResultViewWithText:(NSString *)text
{
    self.searchText = text;
    
    [self search];
    
    if (self.histroyList == nil) {
        self.histroyList = [ForumSearchManager historyForumList];
    }
    
    if ([self.searchText length] > 0) { //有输入内容
        self.type = SearchListTypeResult;
        self.searchResultTableView.hidden = NO;
    } else if ([self.histroyList count] > 0) { //无输入内容，但有历史记录
        self.type = SearchListTypeHistory;
        self.searchResultTableView.hidden = NO;
    } else {
        self.searchResultTableView.hidden = YES;
    }
    
    [self.searchResultTableView reloadData];
}

- (void)search
{
    NSString *tempText = [self.searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([tempText length] == 0) {
        [self.searchResultList removeAllObjects];
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
//    char firstChar = [text characterAtIndex:0];
    
    //加载搜索数据源
    if (self.searchSourceData == nil) {
        self.searchSourceData = [ForumSearchManager readSourceData];
    }
    
    //搜索
    self.searchResultList = [NSMutableArray array];
    
    if ([text length] > 0) {
        for (NSDictionary *oneCityData in [self.searchSourceData validArrayValueForKey:@"l"]) {
            NSString *cityName = [oneCityData validStringValueForKey:@"c"];
            NSArray *forumList = [oneCityData validArrayValueForKey:@"l"];
            for (NSDictionary *oneForum in forumList) {
                NSString *name = [oneForum validStringValueForKey:@"n"];
                NSString *quanpin = [oneForum validStringValueForKey:@"p"];
                
                //NSArray *pinyinList = [quanpin componentsSeparatedByString:@" "];
                
                BOOL nameFound = NO;
                BOOL pinyinFound = NO;
                

                if ([text validateEnglish]) {
                    pinyinFound = ([quanpin rangeOfString:text].location != NSNotFound);
                }else{
                    nameFound = ([name rangeOfString:text].location != NSNotFound);
                }
                
                
//                //进入拼音搜索
//                if (firstChar >= 'a' && firstChar <= 'z') {
//                    
//                    //输入包含空格
//                    //if ([text rangeOfString:@" "].location != NSNotFound) {
//                        pinyinFound = ([quanpin rangeOfString:text].location != NSNotFound);
//                        
//                    //}
//                    
//                    //输入不包含空格
////                    else {
////                        for (NSString *one in pinyinList) {
////                            if ([one rangeOfString:text].location != NSNotFound) {
////                                pinyinFound = YES;
////                                break;
////                            }
////                        }
////                    }
//                }
//                
//                //进入名字搜索
//                else {
//                    nameFound = ([name rangeOfString:text].location != NSNotFound);
//                }
                

                if (nameFound || pinyinFound) {
                    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:oneForum];
                    [resultDic setObject:cityName forKey:@"c"];
                    [self.searchResultList addObject:resultDic];
                }
            }
        }
    }

    HDLog(@"count:%@", [@([self.searchResultList count]) stringValue]);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.inputTextField resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.type == SearchListTypeHistory) {
        NSUInteger listCount = [self.histroyList count];
        if ([self hasHistory]) {
            listCount += 1;
        }
        return listCount;
    } else {
        return [self.searchResultList count];
    }
}

- (BOOL)hasHistory
{
    return ([self.histroyList count] > 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //清除的cell
    if (self.type == SearchListTypeHistory
        && [self hasHistory]
        && indexPath.row == [self.histroyList count]) {
        
        NSString *identifier = [ClearSearchHistoryCell getCellIdentifier];
        ClearSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [ClearSearchHistoryCell createCell];
        }
        UIImageView *bv = [[UIImageView alloc] initWithImage:[SportImage otherCellBackground3Image]] ;
        [cell setBackgroundView:bv];
        return cell;
    }
    
    //结果的cell
    else {
        NSString *identifier = [ForumSearchResultCell getCellIdentifier];
        ForumSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [ForumSearchResultCell createCell];
        }
        BOOL isLast = NO;
        NSDictionary *forum = nil;
        if (self.type == SearchListTypeHistory) {
            forum = [self.histroyList objectAtIndex:indexPath.row];
            isLast = NO;
        } else {
            forum = [self.searchResultList objectAtIndex:indexPath.row];
            isLast = (indexPath.row == ([self.searchResultList count] - 1));
        }
        [cell updateCellWith:[forum validStringValueForKey:@"n"]
                        city:[forum validStringValueForKey:@"c"]
                   indexPath:indexPath
                      isLast:isLast];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *clickOne = nil;
    if (self.type == SearchListTypeHistory) {
        if (indexPath.row < [self.histroyList count]) {
            
            [MobClickUtils event:umeng_event_forum_search_click_history];
            clickOne = [self.histroyList objectAtIndex:indexPath.row];
            
        } else {
            
            [MobClickUtils event:umeng_event_forum_search_click_clear];
            self.histroyList = [NSArray array];
            [ForumSearchManager clearHistroy];
            [tableView reloadData];
        }
        
    } else {
        
        [MobClickUtils event:umeng_event_forum_search_click_result];
        clickOne = [self.searchResultList objectAtIndex:indexPath.row];
    }
    
    if (clickOne) {
        [ForumSearchManager histroyAddForum:clickOne];
        self.histroyList = [ForumSearchManager historyForumList];
        [tableView reloadData];
        
        Forum *forum = [[Forum alloc] init] ;
        forum.forumId = [clickOne validStringValueForKey:@"i"];
        forum.forumName = [clickOne validStringValueForKey:@"n"];
        ForumDetailController *controller = [[ForumDetailController alloc] initWithForum:forum];
        [self.inputTextField resignFirstResponder];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)clickCancelButton:(id)sender {
    [MobClickUtils event:umeng_event_forum_search_click_cancel];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
