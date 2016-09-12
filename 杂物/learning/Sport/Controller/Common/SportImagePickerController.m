//
//  SportImagePickerController.m
//  Sport
//
//  Created by 江彦聪 on 15/6/4.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportImagePickerController.h"
#import "SportProgressView.h"
#import "NoDataView.h"

@interface SportImagePickerController ()

@property (strong, nonatomic) NoDataView *noDataView;
@property (strong, nonatomic) NSMutableArray *assets;

@end

@implementation SportImagePickerController

-(id)initWithDelegate:(id)delegate
    numberOfPhotoCanBeAdded:(NSUInteger)numberOfPhotoCanBeAdded
{
    self = [super initWithDelegate:self];
    if (self) {
        
        self.sportDelegate = delegate;
        
        self.assets = [NSMutableArray array];
        // Show saved photos on top
        self.shouldShowSavedPhotosOnTop = YES;
        self.shouldChangeStatusBarStyle = NO;
        self.selection = self.assets;
        self.maximumNumberOfPhotosToBeSelected = numberOfPhotoCanBeAdded;
        self.toolbarItemsForManagingTheSelection = @[];
        self.isMultipleMode = YES;
    }
    
    return self;
}


- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (status != ALAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意" message:@"请在iPhone的\"设置－隐私-相机\"选项中，允许趣运动访问你的相册!" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self showNoDataView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)didFinishPushFirstController
{
   [self removeNoDataView];
}


#pragma mark - AGImagePickerControllerDelegate methods
- (void)agImagePickerController:(AGImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self.assets setArray:info];
    NSArray *assetsList = [self.assets copy];
    if (_sportDelegate && [_sportDelegate respondsToSelector:@selector(sportImagePickerController:didFinishPickingMediaWithInfo:
)])
    {
        [_sportDelegate sportImagePickerController:(SportImagePickerController *)picker didFinishPickingMediaWithInfo:assetsList];
    }
}

- (void)agImagePickerController:(AGImagePickerController *)picker didFail:(NSError *)error
{
    if (error == nil) {
        [self.assets removeAllObjects];
        HDLog(@"User has cancelled.");
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        
        // We need to wait for the view controller to appear first.
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (NSUInteger)agImagePickerController:(AGImagePickerController *)picker
         numberOfItemsPerRowForDevice:(AGDeviceType)deviceType
              andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (deviceType == AGDeviceTypeiPad)
    {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            return 11;
        else
            return 8;
    } else {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            if (480 == self.view.bounds.size.width) {
                return 6;
            }
            return 7;
        } else
            return 4;
    }
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldDisplaySelectionInformationInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    if (_isMultipleMode == YES) {
        return NO;
    } else {
        return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);
    }
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldShowToolbarForManagingTheSelectionInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return NO;
}

- (AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionModeForAGImagePickerController:(AGImagePickerController *)picker
{
    return AGImagePickerControllerSelectionBehaviorTypeRadio;
}



- (void)removeNoDataView
{
    [self.noDataView removeFromSuperview];
    [SportProgressView dismiss];
}


-(void)showNoDataView
{
    CGRect frame = CGRectMake(0, 20+44, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
    [self.noDataView removeFromSuperview];
    self.noDataView = [NoDataView createNoDataViewWithFrame:frame
                                                       type:NoDataTypeDefault
                                                       tips:@""];
    
    [self.view addSubview:self.noDataView];
    
    [SportProgressView showWithStatus:@"加载中"];
}


@end
