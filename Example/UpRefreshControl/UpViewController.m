//
//  UpViewController.m
//  UpRefreshControl
//
//  Created by pgbo on 07/06/2015.
//  Copyright (c) 2015 pgbo. All rights reserved.
//

#import "UpViewController.h"
#import <UpRefreshControl/UpRefreshControl.h>

@interface UpViewController ()

@property (nonatomic) UpRefreshControl *upRefreshControl;

@end

@implementation UpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _upRefreshControl = [[UpRefreshControl alloc]initWithScrollView:self.tableView action:^(UpRefreshControl *control){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [control finishedLoadingWithStatus:@"Finished refresh" delay:1.f];
        });
    }];
    
    // 添加为列表的子视图
    [self.tableView addSubview:self.upRefreshControl];
    
    // 自定义颜色
    self.upRefreshControl.color = [UIColor blueColor];
    
    // 自定义触发加载更多的阀值
    self.upRefreshControl.refreshThreshold = 64.f;
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.upRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.upRefreshControl scrollViewDidEndDragging];
}

@end
