//
//  ForumService.m
//  Sport
//
//  Created by haodong  on 15/5/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumService.h"
#import "Post.h"
#import "PostPhoto.h"
#import "Forum.h"
#import "BaseConfigManager.h"
#import "ForumSearchManager.h"
#import "PostComment.h"
#import "ForumCacheManager.h"
#import "CommentMessage.h"
#import "ForumEntrance.h"
#import "GSNetwork.h"


@implementation ForumService

+ (Post *)postFromDictionary:(NSDictionary *)dictionary
{
    Post *post = [[Post alloc] init] ;
    post.postId = [dictionary validStringValueForKey:PARA_ID];
    post.avatarImageURL = [dictionary validStringValueForKey:PARA_USER_AVATAR];
    post.userId = [dictionary validStringValueForKey:PARA_USER_ID];
    post.userName = [dictionary validStringValueForKey:PARA_USER_NAME];
    post.lastUpdateTime = [dictionary validDateValueForKey:PARA_LAST_UPDATE_TIME];
    post.content = [dictionary validStringValueForKey:PARA_CONTENT];
    
    NSMutableArray *photoList = [NSMutableArray array];
    for (NSDictionary *one in [dictionary validArrayValueForKey:PARA_ATTACH_LIST]) {
        PostPhoto *photo = [[PostPhoto alloc] init] ;
        photo.photoImageUrl = [one validStringValueForKey:PARA_URL];
        photo.photoThumbUrl = [one validStringValueForKey:PARA_THUMB_URL];
        [photoList addObject:photo];
    }
    post.photoList = photoList;
    post.commentAmount = [dictionary validIntValueForKey:PARA_COMMENT_COUNT];
    
    post.title = [dictionary validStringValueForKey:PARA_TITLE];
    
    post.createTime = [dictionary validDateValueForKey:PARA_ADD_TIME];

    //TO DO
    Forum *forum = [[Forum alloc]init];
    forum.forumId = [dictionary validStringValueForKey:PARA_COTERIE_ID];
    forum.forumName = [dictionary validStringValueForKey:PARA_COTERIE_NAME];
    forum.imageUrl = [dictionary validStringValueForKey:PARA_COTERIE_COVER_IMG];

    post.forum = forum;
    
    return post;
}

+ (void)getPostList:(id<ForumServiceDelegate>)delegate
               type:(PostListType)type
          coterieId:(NSString *)coterieId
             userId:(NSString *)userId
               page:(NSUInteger)page
              count:(NSUInteger)count
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_POST_LIST forKey:PARA_ACTION];
        [inputDic setValue:[@(type) stringValue] forKey:PARA_TYPE];
        [inputDic setValue:coterieId forKey:PARA_COTERIE_ID];
        [inputDic setValue:userId forKey:PARA_V_USER_ID];
        [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
        [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
        [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_POST parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        //处理热门的缓存
        if (type == PostListTypeHot && page == 1) {
            NSMutableDictionary *cacheInput = [NSMutableDictionary dictionary];
            [cacheInput setValue:VALUE_ACTION_GET_POST_LIST forKey:PARA_ACTION];
            [cacheInput setValue:[@(type) stringValue] forKey:PARA_TYPE];
            [cacheInput setValue:[@(page) stringValue] forKey:PARA_PAGE];
            [cacheInput setValue:@"2.0" forKey:PARA_VER];
            
            if ([status isEqualToString:STATUS_SUCCESS]) {
                [ForumCacheManager saveResultDictionary:resultDictionary inputDictionay:cacheInput];
            } else {
                resultDictionary = [ForumCacheManager readResultDictionaryWithInputDictionay:cacheInput];
            }
        }
        
        //处理圈子详情的缓存
        if (type == PostListTypeInCoterie && page == 1) {
            NSMutableDictionary *cacheInput = [NSMutableDictionary dictionary];
            [cacheInput setValue:VALUE_ACTION_GET_POST_LIST forKey:PARA_ACTION];
            [cacheInput setValue:[@(type) stringValue] forKey:PARA_TYPE];
            [cacheInput setValue:coterieId forKey:PARA_COTERIE_ID];
            [cacheInput setValue:[@(page) stringValue] forKey:PARA_PAGE];
            [cacheInput setValue:@"2.0" forKey:PARA_VER];
            
            if ([status isEqualToString:STATUS_SUCCESS]) {
                NSString *filePath = [ForumCacheManager saveResultDictionary:resultDictionary inputDictionay:cacheInput];
                [ForumCacheManager addOneForumDetailCacheFilePath:filePath];
            } else {
                resultDictionary = [ForumCacheManager readResultDictionaryWithInputDictionay:cacheInput];
            }
        }
        
        //解析数据
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *sourceList = [NSMutableArray array];
        for (NSDictionary *one in list) {
            if (![one isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            Post *post = [self postFromDictionary:one];
            [sourceList addObject:post];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetPostList:page:status:msg:)]) {
                [delegate didGetPostList:sourceList page:page status:status msg:msg];
            }
        });
    }];
}

+ (Forum *)forumFromDictionry:(NSDictionary *)dictionary
{
    Forum *forum = [[Forum alloc] init] ;
    forum.forumId = [dictionary validStringValueForKey:PARA_ID];
    forum.forumName = [dictionary validStringValueForKey:PARA_NAME];
    forum.imageUrl = [dictionary validStringValueForKey:PARA_COVER_IMG];
    forum.currentPostCount = [dictionary validIntValueForKey:PARA_CURRENT_POST_COUNT];
    forum.totalPostCount = [dictionary validIntValueForKey:PARA_POST_COUNT];
    forum.isOftenGoTo = [dictionary validBoolValueForKey:PARA_OFTEN_GO_TO];
    return forum;
}

+ (void)getCoterieList:(id<ForumServiceDelegate>)delegate
                  page:(NSUInteger)page
                 count:(NSUInteger)count
                userId:(NSString *)userId
                cityId:(NSString *)cityId
              regionId:(NSString *)regionId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COTERIE_LIST forKey:PARA_ACTION];
    [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
    [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_POST parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        //处理首页圈子列表的缓存
        if (page == 1) {
            NSMutableDictionary *cacheInput = [NSMutableDictionary dictionary];
            [cacheInput setValue:VALUE_ACTION_GET_COTERIE_LIST forKey:PARA_ACTION];
            [cacheInput setValue:[@(page) stringValue] forKey:PARA_PAGE];
            [cacheInput setValue:@"2.0" forKey:PARA_VER];
            
            if ([status isEqualToString:STATUS_SUCCESS]) {
                [ForumCacheManager saveResultDictionary:resultDictionary inputDictionay:cacheInput];
            } else {
                resultDictionary = [ForumCacheManager readResultDictionaryWithInputDictionay:cacheInput];
            }
        }
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *sourceList = [NSMutableArray array];

        for (NSDictionary *one in list) {
            if (![one isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            Forum *forum = [self forumFromDictionry:one];
            [sourceList addObject:forum];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetCoterieList:page:status:msg:)]) {
                [delegate didGetCoterieList:sourceList page:page status:status msg:msg];
            }
        });
    }];
}

#define KEY_FORUM_SEARCH_DATA_VERSION @"KEY_FORUM_SEARCH_DATA_VERSION"
+ (void)searchStaticData:(id<ForumServiceDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *localVersion = [defaults objectForKey:KEY_FORUM_SEARCH_DATA_VERSION];
        NSString *onlineVersion = [[BaseConfigManager defaultManager] forumSearchDataVersion];
        
        if ([localVersion floatValue] < [onlineVersion floatValue]) {
            
            NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
            [inputDic setValue:VALUE_ACTION_SEARCH_STATIC_DATA forKey:PARA_ACTION];
        [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_POST parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
                NSDictionary *resultDictionary = response.jsonResult;

            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            
            if ([status isEqualToString:STATUS_SUCCESS]) {
                BOOL saveResult = [ForumSearchManager saveSourceData:data];
                if (saveResult) {
                    NSString *dataVersion = [data validStringValueForKey:@"v"];
                    [defaults setObject:dataVersion forKey:KEY_FORUM_SEARCH_DATA_VERSION];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didSearchStaticData:msg:)]) {
                    [delegate didSearchStaticData:status msg:msg];
                }
            });
        }];
    }
        

    });
}

+ (void)getPostDetail:(id<ForumServiceDelegate>)delegate
               postId:(NSString *)postId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_POST_DETAIL forKey:PARA_ACTION];
    [inputDic setValue:postId forKey:PARA_POST_ID];
        
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_POST parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        Post *post = [self postFromDictionary:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetPostDetail:status:msg:)]) {
                [delegate didGetPostDetail:post status:status msg:msg];
            }
        });
    }];
}

+ (void)getCommentList:(id<ForumServiceDelegate>)delegate
                postId:(NSString *)postId
                  page:(NSUInteger)page
                 count:(NSUInteger)count
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_COMMENT_LIST forKey:PARA_ACTION];
        [inputDic setValue:postId forKey:PARA_POST_ID];
        [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
        [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
        [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_POST parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        
        NSMutableArray *sourceList = [NSMutableArray array];
        for (NSDictionary *one in list) {
            PostComment *post = [self commentFromDictionary:one];
            [sourceList addObject:post];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetCommentList:page:status:msg:)]) {
                [delegate didGetCommentList:sourceList page:page status:status msg:msg ];
            }
        });
    }];
}

+ (PostComment *)commentFromDictionary:(NSDictionary *)dictionary
{
    PostComment *comment = [[PostComment alloc] init] ;
    comment.commentId = [dictionary validStringValueForKey:PARA_COM_ID];
    comment.content = [dictionary validStringValueForKey:PARA_CONTENT];
    comment.postId = [dictionary validStringValueForKey:PARA_POST_ID];
    comment.userId = [dictionary validStringValueForKey:PARA_USER_ID];
    comment.createDate = [dictionary validDateValueForKey:PARA_ADD_TIME];
    comment.userName = [dictionary validStringValueForKey:PARA_USER_NAME];
    comment.avatar = [dictionary validStringValueForKey:PARA_USER_AVATAR];
    
    return comment;
}

+ (void)addComment:(id<ForumServiceDelegate>)delegate
           forumId:(NSString *)forumId
           content:(NSString *)content
            userId:(NSString *)userId
            postId:(NSString *)postId
{
     NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_ADD_COMMENT forKey:PARA_ACTION];
    [inputDic setValue:forumId forKey:PARA_COTERIE_ID];
    [inputDic setValue:content forKey:PARA_CONTENT];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:postId forKey:PARA_POST_ID];
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_POST parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSString *commentId = [data validStringValueForKey:PARA_COM_ID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didAddComment:status:msg:)]) {
                [delegate didAddComment:commentId status:status msg:msg];
            }
        });
    }];
}

+ (void)addPost:(id<ForumServiceDelegate>)delegate
      coterieId:(NSString *)coterieId
        content:(NSString *)content
         userId:(NSString *)userId
      attachIds:(NSString *)attachIds
{
          NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ADD_POST forKey:PARA_ACTION];
        [inputDic setValue:coterieId forKey:PARA_COTERIE_ID];
        [inputDic setValue:content forKey:PARA_CONTENT];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:attachIds forKey:PARA_ATTACH_IDS];
        
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_POST parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSString *postId = [data validStringValueForKey:PARA_POST_ID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didAddPost:status:msg:)]) {
                [delegate didAddPost:postId status:status msg:msg];
            }
        });
    }];

}

+ (void)postImage:(id<ForumServiceDelegate>)delegate
        coterieId:(NSString *)coterieId
           userId:(NSString *)userId
            image:(UIImage *)image
      uploadTimestamp:(NSString *)timestamp
{
     NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_POST_IMAGE forKey:PARA_ACTION];
    [inputDic setValue:coterieId forKey:PARA_COTERIE_ID];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    
    [GSNetwork postWithBasicUrlString:SPORT_URL_FORUM_IMAGE parameters:inputDic image:image responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        PostPhoto *photo = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            photo = [[PostPhoto alloc] init] ;
            photo.photoId = [data validStringValueForKey:PARA_ATTACH_ID];
            photo.photoImageUrl = [data validStringValueForKey:PARA_IMAGE_URL];
            photo.photoThumbUrl = [data validStringValueForKey:PARA_THUMB_URL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didPostImage:status:msg:uploadTimestamp:)]) {
                [delegate didPostImage:photo status:status msg:msg uploadTimestamp:timestamp];
            }
        });
    }];
}

+ (void)delImage:(id<ForumServiceDelegate>)delegate
       coterieId:(NSString *)coterieId
          userId:(NSString *)userId
        attachId:(NSString *)attachId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_DEL_IMAGE forKey:PARA_ACTION];
        [inputDic setValue:coterieId forKey:PARA_COTERIE_ID];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:attachId forKey:PARA_ATTACH_ID];
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_IMAGE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didDelImage:msg:attachId:)]) {
                [delegate didDelImage:status msg:msg attachId:attachId];
            }
        });
    }];

}

+ (void)hotTopic:(id<ForumServiceDelegate>)delegate
        venuesId:(NSString *)venuesId
          userId:(NSString *)userId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_HOT_TOPIC forKey:PARA_ACTION];
    [inputDic setValue:venuesId forKey:PARA_VENUES_ID];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_POST parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        ForumEntrance *entrance = nil;
        if ([status isEqualToString:STATUS_SUCCESS] &&
            [data validStringValueForKey:PARA_COTERIE_ID]) {
            
            entrance = [[ForumEntrance alloc] init] ;
            entrance.forumId = [data validStringValueForKey:PARA_COTERIE_ID];
            entrance.forumName = [data validStringValueForKey:PARA_COTERIE_NAME];
            entrance.title = [data validStringValueForKey:PARA_TITLE];
            entrance.coverImageUrl= [data validStringValueForKey:PARA_THUMB_URL];
            entrance.content = [data validStringValueForKey:PARA_CONTENT];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didHotTopic:status:msg:)]) {
                [delegate didHotTopic:entrance status:status msg:msg];
            }
        });
    }];
}

+ (void)getCommentMessageList:(id<ForumServiceDelegate>)delegate
                       userId:(NSString *)userId
                         page:(NSUInteger)page
                        count:(NSUInteger)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_COMMENT_MESSAGE_LIST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
    [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:SPORT_URL_FORUM_MESSAGE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *resultList = [NSMutableArray array];
        for (NSDictionary *one in list) {
            if (![one isKindOfClass:[NSDictionary class]]){
                continue;
            }
            CommentMessage *post = [self messageFromDictionary:one];
            [resultList addObject:post];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetCommentMessageList:page:status:msg:)]) {
                [delegate didGetCommentMessageList:resultList page:page status:status msg:msg];
            }
        });
    }];
}

+ (CommentMessage *)messageFromDictionary:(NSDictionary *)dictionary
{
    CommentMessage *comment = [[CommentMessage alloc] init] ;
    comment.commentId = [dictionary validStringValueForKey:PARA_COM_ID];
    comment.commentContent = [dictionary validStringValueForKey:PARA_COM_CONTENT];
    comment.postId = [dictionary validStringValueForKey:PARA_POST_ID];
    comment.postContent = [dictionary validStringValueForKey:PARA_POST_CONTENT];
    comment.fromUserId = [dictionary validStringValueForKey:PARA_FROM_USER_ID];
    comment.toUserId = [dictionary validStringValueForKey:PARA_TO_USER_ID];
    comment.hasAttach = [dictionary validBoolValueForKey:PARA_HAS_ATTACH];
    comment.imageUrl = [dictionary validStringValueForKey:PARA_IMAGE_URL];
    comment.thumbUrl =[dictionary validStringValueForKey:PARA_THUMB_URL];
    comment.createTime = [dictionary validDateValueForKey:PARA_ADD_TIME];
    comment.fromUserName = [dictionary validStringValueForKey:PARA_FROM_USER_NAME];
    comment.fromUserAvatarUrl= [dictionary validStringValueForKey:PARA_FROM_USER_AVATAR];
    
    return comment;
}


@end
