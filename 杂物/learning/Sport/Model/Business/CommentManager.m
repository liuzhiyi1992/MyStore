//
//  CommentManager.m
//  Sport
//
//  Created by haodong  on 13-7-28.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "CommentManager.h"
#import "SportNetworkContent.h"
#import "NSDictionary+JsonValidValue.h"
#import "Review.h"
#import "BusinessPhoto.h"

@implementation CommentManager

//+ (NSArray *)firstCommentListByDictionary:(NSDictionary *)dictionary
//{
//    NSString *status = [dictionary validStringValueForKey:PARA_STATUS];
//    if ([status isEqualToString:STATUS_SUCCESS] == NO) {
//        return nil;
//    }
//    id firstCommentListSource = [dictionary objectForKey:PARA_COMMENTS];
//    if ([firstCommentListSource isKindOfClass:[NSArray class]] == NO) {
//        return nil;
//    }
//    NSMutableArray *firstCommentListTarget = [NSMutableArray array];
//    for (id oneFirstComment in (NSArray *)firstCommentListSource) {
//        if ([oneFirstComment isKindOfClass:[NSDictionary class]] == NO){
//            continue;
//        }
//        FirstComment *firstComment = [[[FirstComment alloc] init] autorelease];
//        firstComment.commentId = [oneFirstComment validStringValueForKey:PARA_COMMENT_ID];
//        firstComment.userId = [oneFirstComment validStringValueForKey:PARA_USER_ID];
//        firstComment.avatar = [oneFirstComment validStringValueForKey:PARA_AVATAR];
//        firstComment.nickName = [oneFirstComment validStringValueForKey:PARA_NICK_NAME];
//        firstComment.createDate = [NSDate dateWithTimeIntervalSince1970:[oneFirstComment validDoubleValueForKey:PARA_CREATE_TIME]];
//        firstComment.content = [oneFirstComment validStringValueForKey:PARA_CONTENT];
//        firstComment.bussinessId = [oneFirstComment validStringValueForKey:PARA_BUSINESS_ID];
//        
//        NSMutableArray *replyListTarget = [NSMutableArray array];
//        id replyListSource = [oneFirstComment objectForKey:PARA_REPLY_COMMENTS];
//        if ([replyListSource isKindOfClass:[NSArray class]]) {
//            for (id reply in (NSArray *)replyListSource) {
//                if ([reply isKindOfClass:[NSDictionary class]] == NO){
//                    continue;
//                }
//                Comment *comment = [[[Comment alloc] init] autorelease];
//                comment.commentId = [reply validStringValueForKey:PARA_COMMENT_ID];
//                comment.userId = [reply validStringValueForKey:PARA_USER_ID];
//                comment.avatar = [reply validStringValueForKey:PARA_AVATAR];
//                comment.nickName = [reply validStringValueForKey:PARA_NICK_NAME];
//                comment.createDate = [NSDate dateWithTimeIntervalSince1970:[reply validDoubleValueForKey:PARA_CREATE_TIME]];
//                comment.content = [reply validStringValueForKey:PARA_CONTENT];
//                comment.bussinessId = [reply validStringValueForKey:PARA_BUSINESS_ID];
//                
//                if ([reply objectForKey:PARA_IS_READ]) {
//                    comment.isRead = ([reply validIntValueForKey:PARA_IS_READ] == 1);
//                } else {
//                    comment.isRead = YES;
//                }
//                
//                if (comment.isRead == NO) {
//                    firstComment.isTipsNotRead = YES;
//                }
//                
//                [replyListTarget addObject:comment];
//            }
//        }
//        firstComment.replyList = replyListTarget;
//        
//        [firstCommentListTarget addObject:firstComment];
//    }
//    return firstCommentListTarget;
//}

+ (NSArray *)reviewListByDictionary:(NSDictionary *)dictionary
{
    id reviewListSource = [dictionary objectForKey:PARA_COMMENTS];
    if ([reviewListSource isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }
    NSMutableArray *reviewListTarget = [NSMutableArray array];
    for (id oneReview in (NSArray *)reviewListSource) {
        if ([oneReview isKindOfClass:[NSDictionary class]] == NO){
            continue;
        }
        Review *review = [[Review alloc] init] ;
        review.reviewId = [oneReview validStringValueForKey:PARA_COMMENT_ID];
        review.rating = [oneReview validFloatValueForKey:PARA_COMMENT_RANK];
        review.content = [oneReview validStringValueForKey:PARA_CONTENT];
        review.createDate = [NSDate dateWithTimeIntervalSince1970:[oneReview validDoubleValueForKey:PARA_CREATE_TIME]];
        review.userId = [oneReview validStringValueForKey:PARA_USER_ID];
        review.avatar = [oneReview validStringValueForKey:PARA_AVATAR];
        review.nickName = [oneReview validStringValueForKey:PARA_USER_NAME];
        review.businessId = [oneReview validStringValueForKey:PARA_BUSINESS_ID];
        review.useful = [oneReview validBoolValueForKey:PARA_USEFUL];
        review.usefulCount = [oneReview validIntValueForKey:PARA_USEFUL_COUNT];
        
        NSDictionary *commentReplyDict = [oneReview validDictionaryValueForKey:PARA_REPLY_LIST];
        if (commentReplyDict) {
            review.commentReply = [commentReplyDict validStringValueForKey:PARA_REPLY_REMARK];
        }
        
        //todo 测试数据
//        if ((arc4random() % 10 > 5)) {
//            review.commentReply = @"asaskjfg啊实打实大苏打圣诞快克了解到哈萨克里见到过和askljgfjklasgfa四大皆空哈斯卡减肥刚卡死了分开两个";
//        }
        
        NSMutableArray *imageListTarget = [NSMutableArray array];
        id imageListSource = [oneReview objectForKey:PARA_IMAGE_LIST];
        if ([imageListSource isKindOfClass:[NSArray class]]) {
            for (id image in (NSArray *)imageListSource) {
                if ([image isKindOfClass:[NSDictionary class]] == NO){
                    continue;
                }
                BusinessPhoto *photo = [[BusinessPhoto alloc] init] ;
                photo.photoImageUrl = [image validStringValueForKey:PARA_IMAGE_URL];
                photo.photoThumbUrl = [image validStringValueForKey:PARA_THUMB_URL];
                
                [imageListTarget addObject:photo];
            }
        }
        review.photoList = imageListTarget;
        
        [reviewListTarget addObject:review];
    }
    return reviewListTarget;
}

@end
