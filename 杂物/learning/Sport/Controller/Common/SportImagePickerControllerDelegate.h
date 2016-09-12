//
//  SportImagePickerControllerDelegate.h
//  Sport
//
//  Created by 江彦聪 on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#ifndef Sport_SportImagePickerControllerDelegate_h
#define Sport_SportImagePickerControllerDelegate_h
@class SportImagePickerController;
@protocol SportImagePickerControllerDelegate <NSObject>

@optional
- (void)sportImagePickerController:(SportImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;

@end

#endif
