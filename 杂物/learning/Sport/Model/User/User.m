//
//  User.m
//  Sport
//
//  Created by haodong  on 13-6-7.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "User.h"
#import "UIImageView+WebCache.h"
#import "BusinessCategoryManager.h"

@implementation User

- (UIImage *)defaultAvatar
{
    return [SportImage avatarDefaultImage];
}

- (NSString *)birthdayString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:_birthday];
    return dateString;
}

- (NSString *)genderDescription
{
    if ([_gender isEqualToString:GENDER_MALE]) {
        return DDTF(@"kMan");
    } else {
        return DDTF(@"kFemale");
    }
}

- (NSString *)favoriteSportIdListToString
{
    NSMutableString *mutableString = [NSMutableString stringWithString:@""];
    int index = 0;
    for (NSString *categoryId in _favoriteSportIdList) {
        if (index > 0) {
            [mutableString appendString:@","];
        }
        [mutableString appendString:categoryId];
        index ++;
    }
    return mutableString;
}

- (OpenInfo *)openInfoWithType:(NSString *)openType
{
    for (OpenInfo *info in _openInfoList) {
        if ([openType isEqualToString:info.openType]) {
            return info;
        }
    }
    return nil;
}

- (void)deleteAlumb:(NSString *)photoId
{
    NSMutableArray *mu = [NSMutableArray array];
    for (UserPhoto *one in self.albumList) {
        if ([one.photoId isEqualToString:photoId] == NO) {
            [mu addObject:one];
        }
    }
    self.albumList = mu;
}

- (void)deleteEquipment:(NSString *)photoId
{
    NSMutableArray *mu = [NSMutableArray array];
    for (UserPhoto *one in self.equipmentList) {
        if ([one.photoId isEqualToString:photoId] == NO) {
            [mu addObject:one];
        }
    }
    self.equipmentList = mu;
}

- (void)addPhotoToAlumb:(UserPhoto *)photo
{
    NSMutableArray *mu = [NSMutableArray arrayWithArray:self.albumList];
    [mu addObject:photo];
    self.albumList = mu;
}

- (void)addPhotoToEquipment:(UserPhoto *)photo
{
    NSMutableArray *mu = [NSMutableArray arrayWithArray:self.equipmentList];
    [mu addObject:photo];
    self.equipmentList = mu;
}

@end
