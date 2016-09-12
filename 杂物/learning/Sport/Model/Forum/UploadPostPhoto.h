//
//  UploadPostPhoto.h
//  Sport
//
//  Created by 江彦聪 on 15/5/18.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PostPhoto.h"

@interface UploadPostPhoto : PostPhoto
typedef enum {
    UploadStateNewlyAdd = 0,
    UploadStateUploading,
    UploadStateUploadSuccess,
    UploadStateUploadFailed,
}UploadState;
@property(copy, nonatomic) NSString *timestamp;
@property(assign, nonatomic) UploadState uploadState;
@property(assign, nonatomic) BOOL isDelete;
@property(strong, nonatomic) UIImage *photoImage;
@property(strong, nonatomic) UIImage *thumbImage;
@end
