//
//  UITabBarController+SportTabBarController.m
//  Sport
//
//  Created by xiaoyang on 15/11/11.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "UITabBarController+SportTabBarController.h"

@implementation UITabBarController (SportTabBarController)

#define BASE_RED_POINT_TAG  300

- (void)showRedPointWithIndex:(NSUInteger)index
{
    UIViewController *controller = nil;
    if ([self.viewControllers count] > index) {
        controller = [self.viewControllers objectAtIndex:index];
    }
    
    if (controller.tabBarItem.badgeValue) {
        [self hideRedPointWithIndex:index];
        return;
    }
    
    UIView *subView = [self.tabBar viewWithTag:BASE_RED_POINT_TAG + index];
    if (subView) {
        return;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"count_background_red"]];
    imageView.tag = BASE_RED_POINT_TAG + index;
    CGRect buttonFrame = [UITabBarController frameForTabInTabBar:self.tabBar withIndex:index];
    CGFloat oneTabWidth = buttonFrame.size.width ;
    CGFloat x = buttonFrame.origin.x + oneTabWidth / 2;
    CGRect frame = CGRectMake(x+6, 6, 8, 8);
    imageView.frame = frame;
    [self.tabBar addSubview:imageView];
}

- (void)hideRedPointWithIndex:(NSUInteger)index
{
    UIView *subView = [self.tabBar viewWithTag:BASE_RED_POINT_TAG + index];
    if ([subView isKindOfClass:[UIImageView class]]) {
        [subView removeFromSuperview];
    }
}

+ (CGRect)frameForTabInTabBar:(UITabBar*)tabBar withIndex:(NSUInteger)index
{
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:[tabBar.items count]];
    for (UIView *view in tabBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")] && [view respondsToSelector:@selector(frame)]) {
            // check for the selector -frame to prevent crashes in the very unlikely case that in the future
            // objects thar don't implement -frame can be subViews of an UIView
            [tabBarItems addObject:view];
        }
    }
    if ([tabBarItems count] == 0) {
        // no tabBarItems means either no UITabBarButtons were in the subView, or none responded to -frame
        // return CGRectZero to indicate that we couldn't figure out the frame
        return CGRectZero;
    }
    
    // sort by origin.x of the frame because the items are not necessarily in the correct order
    [tabBarItems sortUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        if (view1.frame.origin.x < view2.frame.origin.x) {
            return NSOrderedAscending;
        }
        if (view1.frame.origin.x > view2.frame.origin.x) {
            return NSOrderedDescending;
        }
        NSAssert(NO, @"%@ and %@ share the same origin.x. This should never happen and indicates a substantial change in the framework that renders this method useless.", view1, view2);
        return NSOrderedSame;
    }];
    
    CGRect frame = CGRectZero;
    if (index < [tabBarItems count]) {
        // viewController is in a regular tab
        UIView *tabView = tabBarItems[index];
        if ([tabView respondsToSelector:@selector(frame)]) {
            frame = tabView.frame;
        }
    }
    else {
        // our target viewController is inside the "more" tab
        UIView *tabView = [tabBarItems lastObject];
        if ([tabView respondsToSelector:@selector(frame)]) {
            frame = tabView.frame;
        }
    }
    return frame;
}

@end
