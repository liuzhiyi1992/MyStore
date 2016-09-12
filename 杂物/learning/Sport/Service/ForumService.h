//
//  ForumService.h
//  Sport
//
//  Created by haodong  on 15/5/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"
#import "Post.h"

@class PostPhoto;
@class ForumEntrance;

typedef enum
{
    PostListTypeInCoterie = 0, //某个圈子内的帖子列表
    PostListTypeInPerson = 1,  //某个人内的帖子列表
    PostListTypeHot = 2,       //热门帖子
} PostListType;

@protocol ForumServiceDelegate <NSObject>
@optional
- (void)didGetPostList:(NSArray *)list
                  page:(NSUInteger)page
                status:(NSString *)status
                   msg:(NSString *)msg;

- (void)didGetCoterieList:(NSArray *)list
                     page:(NSUInteger)page
                   status:(NSString *)status
                      msg:(NSString *)msg;

- (void)didSearchStaticData:(NSString *)status
                        msg:(NSString *)msg;

- (void)didGetPostDetail:(Post *)post
                status:(NSString *)status
                   msg:(NSString *)msg;

- (void)didGetCommentList:(NSArray *)list
                     page:(NSUInteger)page
                   status:(NSString *)status
                      msg:(NSString *)msg;

- (void)didAddComment:(NSString *)commentId
               status:(NSString *)status
                  msg:(NSString *)msg;

- (void)didAddPost:(NSString *)postId
            status:(NSString *)status
               msg:(NSString *)msg;

- (void)didPostImage:(PostPhoto *)photo
              status:(NSString *)status
                 msg:(NSString *)msg
         uploadTimestamp:(NSString *)timestamp;

- (void)didDelImage:(NSString *)status
                msg:(NSString *)msg
           attachId:(NSString *)attachId;

- (void)didHotTopic:(ForumEntrance *)forumEntrance
             status:(NSString *)status
                msg:(NSString *)msg;

- (void)didGetCommentMessageList:(NSArray *)list
                            page:(NSUInteger)page
                   status:(NSString *)status
                      msg:(NSString *)msg;

@end

@interface ForumService : NSObject

+ (void)getPostList:(id<ForumServiceDelegate>)delegate
               type:(PostListType)type
          coterieId:(NSString *)coterieId
             userId:(NSString *)userId
               page:(NSUInteger)page
              count:(NSUInteger)count;

+ (void)getCoterieList:(id<ForumServiceDelegate>)delegate
                  page:(NSUInteger)page
                 count:(NSUInteger)count
                userId:(NSString *)userId
                cityId:(NSString *)cityId
              regionId:(NSString *)regionId;

+ (void)searchStaticData:(id<ForumServiceDelegate>)delegate;

+ (void)getPostDetail:(id<ForumServiceDelegate>)delegate
               postId:(NSString *)postId;

+ (void)getCommentList:(id<ForumServiceDelegate>)delegate
                postId:(NSString *)postId
                  page:(NSUInteger)page
                 count:(NSUInteger)count;

+ (void)addComment:(id<ForumServiceDelegate>)delegate
           forumId:(NSString *)forumId
           content:(NSString *)content
            userId:(NSString *)userId
            postId:(NSString *)postId;

+ (void)addPost:(id<ForumServiceDelegate>)delegate
      coterieId:(NSString *)coterieId
        content:(NSString *)content
         userId:(NSString *)userId
      attachIds:(NSString *)attachIds;

+ (void)postImage:(id<ForumServiceDelegate>)delegate
        coterieId:(NSString *)coterieId
           userId:(NSString *)userId
            image:(UIImage *)image
  uploadTimestamp:(NSString *)timestamp;

+ (void)delImage:(id<ForumServiceDelegate>)delegate
       coterieId:(NSString *)coterieId
          userId:(NSString *)userId
        attachId:(NSString *)attachId;

+ (void)hotTopic:(id<ForumServiceDelegate>)delegate
        venuesId:(NSString *)venuesId
          userId:(NSString *)userId;

+ (void)getCommentMessageList:(id<ForumServiceDelegate>)delegate
                userId:(NSString *)userId
                  page:(NSUInteger)page
                 count:(NSUInteger)count;


@end
