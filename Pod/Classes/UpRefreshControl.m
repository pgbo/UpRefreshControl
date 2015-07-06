//
//  UpRefreshControl.m
//  GalaToy
//
//  Created by guangbo on 15/5/13.
//
//

#import "UpRefreshControl.h"
static const CGFloat UpRefreshControlHeight = 60.f;

@interface UpRefreshControl ()

@property (nonatomic, readonly) UILabel *stateLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, copy) void(^refreshActionHandler)(UpRefreshControl *);
@property (nonatomic) CGFloat originalTopContentInset;

@end

@implementation UpRefreshControl

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
                            action:(void(^)(UpRefreshControl *))actionHandler
{
    if (self = [super initWithFrame:CGRectMake(0,
                                               - UpRefreshControlHeight,
                                               CGRectGetWidth(scrollView.bounds),
                                               UpRefreshControlHeight)]) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _scrollView = scrollView;
        _refreshActionHandler = actionHandler;
        
        // setup sub views
        [self setupSubViews];
        
        // set default threshold
        [self setRefreshThreshold:UpRefreshControlHeight];
        
        // set default color
        [self setColor:[UIColor grayColor]];
        
        [self updateState:UpRefreshControlStateNormal];
    }
    return self;
}

- (void)setupSubViews
{
    _stateLabel = [[UILabel alloc]init];
    self.stateLabel.backgroundColor = [UIColor clearColor];
    self.stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    self.stateLabel.textAlignment = NSTextAlignmentCenter;
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.stateLabel];
    
    NSDictionary *views = @{@"stateLabel":self.stateLabel};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stateLabel]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stateLabel]|" options:0 metrics:nil views:views]];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.activityIndicatorView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.activityIndicatorView.color = color;
    self.stateLabel.textColor = color;
}

- (void)finishedLoadingWithStatus:(NSString *)status
                            delay:(NSTimeInterval)delay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stateLabel.text = status;
        [self updateState:UpRefreshControlStateFinishing];
        
        NSTimeInterval nDelay = delay;
        if (nDelay < 0) {
            nDelay = 0;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(nDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 恢复到原来的位置
            
            UIEdgeInsets newInsets = self.scrollView.contentInset;
            newInsets.top = self.originalTopContentInset;
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [UIView animateWithDuration:.3f animations:^{
                self.scrollView.contentInset = newInsets;
                
            } completion:^(BOOL finished){
                [[UIApplication sharedApplication]endIgnoringInteractionEvents];
                [self updateState:UpRefreshControlStateNormal];
            }];
        });
    });
}

- (void)updateState:(UpRefreshControlState)state
{
    _state = state;
    
    switch (state) {
        case UpRefreshControlStateNormal:
            [self.activityIndicatorView stopAnimating];
            self.stateLabel.alpha = 1.f;
            self.stateLabel.text = UpRefreshControlLocalizedString(@"Pull down to refresh ...");
            break;
        case UpRefreshControlStateReadyRefresh:
            [self.activityIndicatorView stopAnimating];
            self.stateLabel.alpha = 1.f;
            self.stateLabel.text = UpRefreshControlLocalizedString(@"Release to refresh ...");
            break;
        case UpRefreshControlStateRefreshing:
            [self.activityIndicatorView startAnimating];
            self.stateLabel.alpha = 0.f;
            self.stateLabel.text = nil;
            break;
        case UpRefreshControlStateFinishing:
            [self.activityIndicatorView stopAnimating];
            self.stateLabel.alpha = 1.f;
            break;
        default:
            break;
    }
}

#pragma mark - public methods

- (void)scrollViewDidScroll
{
    if (self.state == UpRefreshControlStateRefreshing || self.state == UpRefreshControlStateFinishing) {
        return;
    }
    
    if (!self.scrollView.isDragging) {
        return;
    }
    
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    CGFloat depend = contentOffsetY + self.scrollView.contentInset.top;
    if (depend >= 0) {
        return;
    }
    
    if (depend < 0 && depend > - self.refreshThreshold) {
        // 还没有到达准备刷新的临界点
        if (self.state == UpRefreshControlStateReadyRefresh) {
            [self updateState:UpRefreshControlStateNormal];
        }
        
    } else if (depend < - self.refreshThreshold){
        // 超过刷新的临界点，改变状态刷新
        if (self.state == UpRefreshControlStateNormal) {
            [self updateState:UpRefreshControlStateReadyRefresh];
        }
    }
}

- (void)scrollViewDidEndDragging
{
    if (!self.scrollView.isDragging) {
        if (self.state == UpRefreshControlStateReadyRefresh) {
            [self updateState:UpRefreshControlStateRefreshing];
            
            _originalTopContentInset = self.scrollView.contentInset.top;
            
            UIEdgeInsets newInsets = self.scrollView.contentInset;
            newInsets.top = self.originalTopContentInset + UpRefreshControlHeight;
            self.scrollView.contentInset = newInsets;
            
            __weak typeof(self)weakSelf = self;
            if (self.refreshActionHandler) {
                self.refreshActionHandler(weakSelf);
            }
        }
    }
}


+ (NSBundle *)upRefreshControlBundle
{
    return [NSBundle bundleWithPath:[self upRefreshControlBundlePath]];
}

+ (NSString *)upRefreshControlBundlePath
{
    return [[NSBundle bundleForClass:[UpRefreshControl class]]
            pathForResource:@"UpRefreshControl" ofType:@"bundle"];
}

@end
