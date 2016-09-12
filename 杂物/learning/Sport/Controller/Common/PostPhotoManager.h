//
//  PostPhotoManager.h
//  Sport
//
//  Created by 江彦聪 on 16/5/6.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
@class UploadPostPhoto;

@protocol PostPhotoManagerDelegate <NSObject>
- (void)updatePhotoUI;
- (void)postSelectedImage:(UploadPostPhoto *)uploadPhoto;
- (void)addPostWithAttachIds:(NSString *)attachIds;
- (void)deleteImageWithAttachId:(NSString *)attachId;
@end

@interface PostPhotoManager : NSObject
@property (strong, nonatomic) NSMutableArray *selectedPhotoList;

-(instancetype) initWithController:(UIViewController<PostPhotoManagerDelegate> *) controller maxPhotoCount:(int)count;
-(void) showOrDeleteImageWithIndex:(int)index;
-(void) addPost;
-(void) cleanPhotoManager;
-(void) didPostSelectedImageWithStatus:(NSString *)status
                                   key:(NSString *)key
                              attachId:(NSString *)photoId
                              imageUrl:(NSString *)imageUrl
                              thumbUrl:(NSString *)thumbUrl;
@end
