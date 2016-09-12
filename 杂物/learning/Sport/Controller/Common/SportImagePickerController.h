//
//  SportImagePickerController.h
//  Sport
//
//  Created by 江彦聪 on 15/6/4.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "AGImagePickerController.h"
@class SportImagePickerController;
@protocol SportImagePickerControllerDelegate <NSObject>
@optional
- (void)sportImagePickerController:(SportImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
@end

@interface SportImagePickerController : AGImagePickerController<AGImagePickerControllerDelegate>

@property (assign, nonatomic) id<SportImagePickerControllerDelegate> sportDelegate;
@property (assign, nonatomic) BOOL isMultipleMode;
-(id)initWithDelegate:(id)delegate
numberOfPhotoCanBeAdded:(NSUInteger)numberOfPhotoCanBeAdded;

@end
