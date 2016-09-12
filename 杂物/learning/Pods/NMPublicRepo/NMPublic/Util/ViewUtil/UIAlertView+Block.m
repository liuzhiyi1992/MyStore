//
//  UIAlertView+Block.m
//  Pods
//
//  Created by 江彦聪 on 16/6/19.
//
//

#import "UIAlertView+Block.h"
#import <objc/runtime.h>

@implementation UIAlertView (Block)
static char key;
-  (void)showAlertViewWithCompleteBlock:(CompleteBlock)block {
    //首先判断这个block是否存在
    if(block) {
        //这里用到了runtime中绑定对象，将这个block对象绑定alertview上
        objc_setAssociatedObject(self, &key,block,OBJC_ASSOCIATION_COPY);
        //设置delegate
        self.delegate=self;
    }
    //弹出提示框
    [self show];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)btnIndex {
    //拿到之前绑定的block对象
    CompleteBlock block =objc_getAssociatedObject(self, &key);
    //移除所有关联
    objc_removeAssociatedObjects(self);
    if(block) {
        //调用block 传入此时点击的按钮index
        block(btnIndex);
    }
}

@end
