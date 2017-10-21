//
//  DMProgressView.m
//  DMProgressViewDemo
//
//  Created by Damon on 2017/9/1.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMProgressView.h"

#define padding 20

@interface DMProgressView ()

//进度圈View
@property (nonatomic, strong)CAShapeLayer *processLayer;
@property (nonatomic, strong)UILabel *labProcess;

//加载中loadingView
@property (nonatomic, strong)UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong)UILabel *labLoading;

#warning recode
@property (nonatomic, strong) UIView *vBackground;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, assign) CGFloat customWidth;
@property (nonatomic, assign) CGFloat customHeight;

@end

@implementation DMProgressView

- (CAShapeLayer *)processLayer {
    
    if (!_processLayer) {
        
        _processLayer = [[CAShapeLayer alloc] init];
        _processLayer.lineWidth = 2.0;
        _processLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _processLayer.fillColor = [[UIColor clearColor] CGColor];
        
        [self.layer addSublayer:self.processLayer];
    }
    
    return _processLayer;
}

- (UILabel *)labProcess {
    
    if (!_labProcess) {
        
        _labProcess = [[UILabel alloc] init];
        _labProcess.textColor = [UIColor whiteColor];
        _labProcess.textAlignment = NSTextAlignmentCenter;
        [_labProcess sizeToFit];
        
        [self.layer addSublayer:_labProcess.layer];
    }
    
    return _labProcess;
}

- (void)drawRect:(CGRect)rect {
    
    CGPoint center = CGPointMake(_customWidth*0.5, _customHeight*0.5);
    CGFloat radius = _customWidth*0.5;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:3*M_PI_2 endAngle:3*M_PI_2+2*M_PI*_progress clockwise:YES];
    self.progressLayer.path = [path CGPath];
    
//    self.labProcess.frame = CGRectMake(0, 0, rect.size.width, rect.size.height*0.5);
//    self.labProcess.center = center;
//    self.labProcess.text = [NSString stringWithFormat:@"%.0f", self.process*100];
//    
//    self.labProcess.hidden = self.process>0?NO:YES;
    
}

- (void)setProcess:(CGFloat)process {
    
    _process = process;
    
    //2%预显示
    _process = _process > 0.02 ? _process : 0.02;
    
    [self setNeedsDisplay];
    
}

#pragma mark - 进度View
//【显示】进度View
+ (instancetype)showProgressViewAddedTo1:(UIView *)view {
    
    for (DMProgressView *progressView in view.subviews) {
        
        if ([progressView isKindOfClass:[DMProgressView class]]) {
            
            //[progressView removeFromSuperview];
            return progressView;
        }
    }
    
    DMProgressView *progressView = [[self alloc] init];
    progressView.backgroundColor = [UIColor clearColor];
    
    progressView.frame = CGRectMake(0, 0, 40, 40);
    progressView.center = CGPointMake(view.bounds.size.width*0.5, view.bounds.size.height*0.5);
    
    [view addSubview:progressView];
    
    return progressView;
}

//【隐藏】进度View
- (void)hideProgressView {
    
    [self.labProcess.layer removeFromSuperlayer];
    [self removeFromSuperview];

}

#pragma mark - 加载View
//【显示】loadingView
+ (instancetype)showLoadingViewAddTo1:(UIView *)view {

    for (DMProgressView *loadingView in view.subviews) {
        
        if ([loadingView isKindOfClass:[DMProgressView class]]) {
            
            return loadingView;
        }
    }
    
    DMProgressView *progressView = [[DMProgressView alloc] init];
    progressView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6];
    progressView.layer.masksToBounds = YES;
    progressView.layer.cornerRadius = 5;
    progressView.frame = CGRectMake(0, 0, 100, 100);
    progressView.center = CGPointMake(view.bounds.size.width*0.5, view.bounds.size.height*0.5);
    
    //加载圈
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    progressView.activityIndicatorView = activityIndicatorView;
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndicatorView.center = CGPointMake(progressView.bounds.size.width*0.5, progressView.bounds.size.height*0.5-15);
    
    [activityIndicatorView startAnimating];
    
    //文字
    UILabel *labLoading = [[UILabel alloc] init];
    progressView.labLoading = labLoading;
    labLoading.text = @"正在加载...";
    labLoading.font = [UIFont systemFontOfSize:14.0];
    labLoading.textColor = [UIColor whiteColor];
    labLoading.textAlignment = NSTextAlignmentCenter;
    [labLoading sizeToFit];
    labLoading.frame = CGRectMake(0, 0, progressView.bounds.size.width, 30);
    labLoading.center = CGPointMake(progressView.bounds.size.width*0.5, progressView.bounds.size.height*0.5+30);
    
    [view addSubview:progressView];
    [progressView addSubview:activityIndicatorView];
    [progressView addSubview:labLoading];
    
    return progressView;
}


//【隐藏】loadingView
- (void)hideLoadingView {

    [self removeFromSuperview];
}

#pragma mark - 成功提示View
//【显示
+ (instancetype)showSuccessAddedTo:(UIView *)view message:(NSString *)message {

    for (DMProgressView *loadingView in view.subviews) {
        
        if ([loadingView isKindOfClass:[DMProgressView class]]) {
            
            return loadingView;
        }
    }
    
    DMProgressView *progressView = [[DMProgressView alloc] init];
    progressView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6];
    progressView.layer.masksToBounds = YES;
    progressView.layer.cornerRadius = 5;
    progressView.frame = CGRectMake(0, 0, 100, 100);
    progressView.center = CGPointMake(view.bounds.size.width*0.5, view.bounds.size.height*0.5);
    progressView.alpha = 0;
    
    //成功图标
    UIImageView *ivSuccess = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProgressSuccess"]];
    ivSuccess.frame = CGRectMake(0, 0, 35, 35);
    ivSuccess.center = CGPointMake(progressView.bounds.size.width*0.5, progressView.bounds.size.height*0.5-15);
    
    //文字
    UILabel *labLoading = [[UILabel alloc] init];
    progressView.labLoading = labLoading;
    labLoading.text = message;
    labLoading.font = [UIFont systemFontOfSize:14.0];
    labLoading.textColor = [UIColor whiteColor];
    labLoading.textAlignment = NSTextAlignmentCenter;
    [labLoading sizeToFit];
    labLoading.frame = CGRectMake(0, 0, progressView.bounds.size.width, 30);
    labLoading.center = CGPointMake(progressView.bounds.size.width*0.5, progressView.bounds.size.height*0.5+30);
    
    [progressView addSubview:ivSuccess];
    [progressView addSubview:labLoading];
    [view addSubview:progressView];
    
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        
        progressView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [progressView hideSuccessWithView:view];
        });
    }];
    
    return progressView;
}

//【隐藏】成功提示
- (void)hideSuccessWithView:(UIView *)view {
    
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

#warning recode
+ (instancetype)showProgressViewAddedTo:(UIView *)view {

    DMProgressView *progressView = [[self alloc] p_initWithView:view];
    progressView.backgroundColor = [UIColor clearColor];
    [view addSubview:progressView];
    
    [progressView p_show];
    
    return progressView;
}

- (id)p_initWithView:(UIView *)view {

    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        [self p_configCommon];
    }
    
    return self;
}

//Config common parameters
- (void)p_configCommon {
    
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0;
    _margin = 20;
    self.customWidth = 22;
    self.customHeight = 22;
    
    [self p_setUpConponents];
    [self p_updateConstraints];
}

//Set up all of the conponents
- (void)p_setUpConponents {
    
    //Background view
    self.vBackground = [[UIView alloc] init];
    self.vBackground.translatesAutoresizingMaskIntoConstraints = NO;
    self.vBackground.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6];
    self.vBackground.layer.cornerRadius = 5;
    self.vBackground.layer.masksToBounds = YES;
    [self addSubview:self.vBackground];
    
    //Custom view
    _customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_status_success_22x22_"]];
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    //Text label
    _label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont systemFontOfSize:16.0];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.label sizeToFit];
    [self.label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    
    //UIActivityIndicatorView
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _indicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Progress
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.lineWidth = 2.0;
    _progressLayer.strokeColor = [[UIColor whiteColor] CGColor];
    _progressLayer.fillColor = [[UIColor clearColor] CGColor];
}

//Update contraints
- (void)p_updateConstraints {
    
    if (_mode == DMProgressViewModeLoading) {
        
        [_indicator startAnimating];
        self.customView = _indicator;
        [_vBackground addSubview:_customView];
        [_vBackground addSubview:_label];
        [_vBackground removeConstraints:_vBackground.constraints];
        
        self.customWidth = 34;
        self.customHeight = self.customWidth;
        
        //custom
        [self configCustomViewContraints];
        
        //label
        [self configLabelConstraintsWithTopView:_customView];
        
        
        [self updateBgViewWithTopView:_customView bottomView:_label];
        
    } else if (_mode == DMProgressViewModeProgress) {
    
        self.customView = [[UIView alloc] init];
        [_customView.layer addSublayer:_progressLayer];
        [_vBackground addSubview:_customView];
        
        self.customWidth = 34;
        self.customHeight = self.customWidth;
        
        //custom
        [self configCustomViewContraints];
        
        //label
        //[self configLabelConstraintsWithTopView:_customView];
        
        [self updateBgViewWithTopView:_customView bottomView:_customView];
    
    } else if (_mode == DMProgressViewModeStatus || _mode == DMProgressViewModeCustom) {
    
        [_vBackground addSubview:_customView];
        [_vBackground addSubview:_label];
        [_vBackground removeConstraints:_vBackground.constraints];
        [_customView removeConstraints:_customView.constraints];
        
        //custom
        [self configCustomViewContraints];
        
        //label
        [self configLabelConstraintsWithTopView:_customView];
        
        [self updateBgViewWithTopView:_customView bottomView:_label];
    
    } else if (_mode == DMProgressViewModeText) {
    
        //label
        [_vBackground addSubview:_label];
        [_customView removeFromSuperview];
        
        [self configLabelConstraintsWithTopView:nil];
        [self updateBgViewWithTopView:_label bottomView:_label];
    }
}

//Animation show
- (void)p_show {

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        self.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        if (_mode != DMProgressViewModeProgress) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self hide];
            });
        }
    }];
}

- (void)hide {

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

//自定义视图(CustomView)约束
- (void)configCustomViewContraints {
    
    NSMutableArray *cusViewConstraints = [NSMutableArray new];
    
    //水平居中
    [cusViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    //大小
    [_customView addConstraint:[NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_customWidth]];
    [_customView addConstraint:[NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_customHeight]];
    
    [self addConstraints:cusViewConstraints];
}

//约束Label视图
- (void)configLabelConstraintsWithTopView:(UIView *)topView {
    
    NSMutableArray *cusViewConstraints = [NSMutableArray new];
    
    //居中
    [cusViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    //最大宽高
    [cusViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-2*_margin]];
    [cusViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:-2*_margin]];
    
    //上方View间距
    if (topView) {
        CGFloat marginTop = _label.text.length > 0 ? 10 : 0;
        [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1 constant:marginTop]];
    }
    
    [self addConstraints:cusViewConstraints];
}

//适应内容视图(_vBackground)
- (void)updateBgViewWithTopView:(UIView *)topView bottomView:(UIView *)bottomView {
    
    //最大宽高约束
    NSMutableArray *bgConstraints = [NSMutableArray new];
    [bgConstraints addObject:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-2*_margin]];
    [bgConstraints addObject:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:-2*_margin]];
    [self addConstraints:bgConstraints];
    
    //获取比较宽的子视图
    UIView *maxWidthView = topView.bounds.size.width > bottomView.bounds.size.width ? topView : bottomView;
    NSLog(@"%f-%f", topView.bounds.size.width, bottomView.bounds.size.width);
    //根据子视图自适应父视图
    [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeTop multiplier:1 constant:-padding]];
    [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeBottom multiplier:1 constant:padding]];
    [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:maxWidthView attribute:NSLayoutAttributeLeft multiplier:1 constant:-padding]];
    [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:maxWidthView attribute:NSLayoutAttributeRight multiplier:1 constant:padding]];
    

    //内容垂直居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
}


+ (DMProgressView *)progressViewForView:(UIView *)view {

    NSEnumerator *subViewsEnumerator = [view.subviews reverseObjectEnumerator];
    
    for (UIView *subView in subViewsEnumerator) {
        
        if ([subView isKindOfClass:self]) {
            
            return (DMProgressView *)subView;
        }
    }
    
    return nil;
}

- (void)setMode:(DMProgressViewMode)mode {
    
    _mode = mode;
    
    [self p_updateConstraints];
}

- (void)setStatus:(DMProgressViewStatus)status {

    _status = status;
    
    //default width&height
    self.customWidth = 22;
    self.customHeight = self.customWidth;
    
    self.customView = [[UIImageView alloc] init];
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (status == DMProgressViewStatusSuccess) {
        
        ((UIImageView *)_customView).image = [UIImage imageNamed:@"progress_status_success_22x22_"];
        
    } else if (status == DMProgressViewStatusFail) {
    
        ((UIImageView *)_customView).image = [UIImage imageNamed:@"progress_status_fail_24x24_"];
        
    } else if (status == DMProgressViewStatusWarning) {
        
        ((UIImageView *)_customView).image = [UIImage imageNamed:@"progress_status_warning_48x48_"];
    }
    
    [self p_updateConstraints];
}

//custom view
- (void)setCustomView:(UIView *)view width:(CGFloat)width height:(CGFloat)height {

    self.customWidth = width;
    self.customHeight = height;
    
    self.customView = view;
    [self addSubview:_customView];
    
    [self p_updateConstraints];
    
}

- (void)setCustomView:(UIView *)customView {
    
    [_customView removeFromSuperview];
    _customView = customView;
    _customView.frame = CGRectMake(0, 0, _customWidth, _customHeight);
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
}

//限制宽
- (void)setCustomWidth:(CGFloat)customWidth {
    
    CGFloat maxWidth = self.frame.size.width - 2*2*_margin;
    _customWidth = customWidth > maxWidth ? maxWidth : customWidth;
}

//限制高
- (void)setCustomHeight:(CGFloat)customHeight {
    
    CGFloat maxHeight = self.frame.size.height - 2*2*_margin;
    _customHeight  = customHeight > maxHeight ? maxHeight : customHeight;
}

- (void)setProgress:(CGFloat)progress {

    _progress = progress;
    
    //2%预显示
    _progress = _progress > 0.02 ? _progress : 0.02;
    
    [self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"text"]) {
        
        [_label sizeToFit];
        
        [self p_updateConstraints];
    }
}


- (void)dealloc {

    [self.label removeObserver:self forKeyPath:@"text"];
    NSLog(@"%s", __func__);
}

@end
