//
//  SportMWPhotoBrowser.m
//  Sport
//
//  Created by 江彦聪 on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportMWPhotoBrowser.h"

@interface SportMWPhotoBrowser ()
@property (strong, nonatomic) UILabel *rightBarLabel;
@property (assign, nonatomic) int openIndex;
@end

@implementation SportMWPhotoBrowser

-(id)initWithPhotoList:(NSMutableArray *)list
             openIndex:(int) index
{
    self = [self initMWPhotoBrowserWithDelegate:self];
    if (self) {
        self.photoList = list;
        self.openIndex = index;
        self.totalNumber = [list count];
        self.delayToHideElements = 3;

        //一张图片的时候默认隐藏
//        if (self.totalNumber == 1) {
//            self.delayToHideElements = 0;
//        } else {
//        }
    }
    
    return self;
}

-(id)initMWPhotoBrowserWithDelegate:(id <MWPhotoBrowserDelegate>)delegate
{
    self = [super initWithDelegate:self];
    if (self) {
        self.keepNavBarAppearance = YES;
        self.displayActionButton = NO; // Show action button to allow sharing, copying, etc (defaults to YES)
        self.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
        self.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
        self.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
        self.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
        self.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        self.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        //self.wantsFullScreenLayout = YES; // iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
        self.displayExitButtonOnLeft = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setCurrentPhotoIndex:self.openIndex];
    UINavigationBar *navBar = self.navigationController.navigationBar;

    NSDictionary *textAttributes = @{
                                     NSForegroundColorAttributeName : [UIColor whiteColor]
                                     };
    navBar.titleTextAttributes = textAttributes;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [_photoList count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photoList.count) {
        SportMWPhoto *photo = [_photoList objectAtIndex:index];
        
        return photo;
    }
    else {
        return nil;
    }
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index
{
    if (index < _photoList.count) {
        [self setPageViewAtIndex:index];
        SportMWPhoto *photo = [_photoList objectAtIndex:index];
        
        return photo.title;
    }
    else {
        return nil;
    }
}

-(void) setPageViewAtIndex:(NSUInteger)index
{
    SportMWPhoto *photo = [_photoList objectAtIndex:index];
  
    if (self.rightBarLabel == nil) {
        self.rightBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 21)];

        self.rightBarLabel.font = [UIFont systemFontOfSize:14];
        self.rightBarLabel.backgroundColor = [UIColor clearColor];
        self.rightBarLabel.textAlignment = NSTextAlignmentCenter;
        self.rightBarLabel.textColor = [UIColor whiteColor];
        
        UIBarButtonItem *rightPageButton = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarLabel];
        [self.navigationItem setRightBarButtonItem:rightPageButton animated:NO];
    }
    
    [self.rightBarLabel setText:[NSString stringWithFormat:@"   %lu / %lu", (unsigned long)(photo.index + 1), (unsigned long)self.totalNumber]];

}

-(void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser
{
    [MobClickUtils event:umeng_event_mwphoto_done_button];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)singleTapEvent {
    [MobClickUtils event:umeng_event_mwphoto_single_tap];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
