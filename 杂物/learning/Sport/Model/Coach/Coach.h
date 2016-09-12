//
//  Coach.h
//  Sport
//
//  Created by 江彦聪 on 15/7/13.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coach : NSObject

@property (copy, nonatomic) NSString *coachId;
@property (copy, nonatomic) NSString *avatarUrl;            //头像URL
@property (copy, nonatomic) NSString *avatarOriginalUrl;    //原头像URL
@property (copy, nonatomic) NSString *imageUrl;             //主图URL
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *gender;
@property (strong, nonatomic) NSArray *categoryList;
@property (copy, nonatomic) NSString *price;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) int age;                  //教练年龄
@property (assign, nonatomic) int height;               //教练身高
@property (assign, nonatomic) int weight;               //教练重量
@property (assign, nonatomic) int collectNumber;        //被收藏数
@property (assign, nonatomic) int commentCount;         //被评论数
@property (copy, nonatomic) NSString *coachShareUrl;    //分享链接
@property (copy, nonatomic) NSString *rongId;
@property (copy, nonatomic) NSString *oftenArea;        //常驻场地
@property (strong, nonatomic) NSArray *serviceAreaList; //上门服务区域列表
@property (strong, nonatomic) NSArray *photoList;       //相册列表
@property (copy, nonatomic) NSString *introduction;     //介绍
@property (assign, nonatomic) NSUInteger studentCount;  //学员总数
@property (assign, nonatomic) NSUInteger totalTime;     //陪练时长
@property (assign, nonatomic) float rate;               //评价得分
@property (strong, nonatomic) NSArray *commentList;     //评论列表
@property (assign, nonatomic) BOOL isCollect;           //是否被收藏
@property (copy, nonatomic) NSString *isShow;              //是否屏蔽
@property (strong, nonatomic) NSArray *sportExperienceList; //运动经历
@property (strong, nonatomic) NSArray *coachProjectsList; //运动经历
@property (assign, nonatomic) int levelStatus;                //是否通过认证(1未上传2待审核3通过4不通过)
@property (copy, nonatomic) NSString *levelDesc;        //认证说明
@property (strong, nonatomic) NSArray *oftenAreaList;  //常驻场馆列表

@end
