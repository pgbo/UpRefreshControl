//
//  UpRefreshControl.h
//  GalaToy
//
//  Created by guangbo on 15/5/13.
//
//

#import <UIKit/UIKit.h>

#define UpRefreshControlLocalizedString(key) \
NSLocalizedStringFromTableInBundle((key), @"UpRefreshControl", [UpRefreshControl upRefreshControlBundle], nil)

typedef NS_ENUM(NSUInteger, UpRefreshControlState) {
    UpRefreshControlStateNormal = 0,    // 正常
    UpRefreshControlStateReadyRefresh,  // 准备好刷新
    UpRefreshControlStateRefreshing,    // 刷新中
    UpRefreshControlStateFinishing      // 结束中
};

@interface UpRefreshControl : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) UpRefreshControlState state;

/**
 *  下拉的深度用以触发刷新，当下拉到改深度时，松开才能触发刷新
 */
@property (nonatomic) CGFloat refreshThreshold;
@property (nonatomic) UIColor *color;

/**
 *  初始化下拉刷新控件
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView
                            action:(void(^)(UpRefreshControl *))actionHandler;

/**
 *  结束刷新，并显示特定时间的提示信息
 */
- (void)finishedLoadingWithStatus:(NSString *)status delay:(NSTimeInterval)delay;

/**
 *  在scrollView的代理方法scrollViewDidScroll中调用本方法
 */
- (void)scrollViewDidScroll;

/**
 *  在scrollView的代理方法scrollViewDidScroll中调用本方法
 */
- (void)scrollViewDidEndDragging;

+ (NSBundle *)upRefreshControlBundle;

@end
