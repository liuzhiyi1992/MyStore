//
//  ServiceSectionHeaderView.h
//  Sport
//
//  Created by xiaoyang on 15/12/18.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceSectionHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *sectionHeaderViewLabel;

+ (ServiceSectionHeaderView *)createServiceSectionHeaderView; 

+ (CGFloat)height;

@end
