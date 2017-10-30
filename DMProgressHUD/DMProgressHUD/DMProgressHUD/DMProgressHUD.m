//
//  DMProgressHUD.m
//  DMProgressHUDDemo
//
//  Created by Damon on 2017/9/1.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMProgressHUD.h"

#define margin 20

#define animationDuration 0.2

@interface DMProgressHUD ()<CAAnimationDelegate>

@property (nonatomic, strong) UIView *vBackground;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UIImageView *ivIcon;

@property (nonatomic, strong) CAShapeLayer *layerCircle;     //defaule cycle
@property (nonatomic, strong) CAShapeLayer *layerProgress;  //progress cycle
@property (nonatomic, strong) UILabel *labProgress;         //progress lable

@property (nonatomic, assign) CGFloat customWidth;
@property (nonatomic, assign) CGFloat customHeight;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) DMProgressHUDAnimation animation;

@property (nonatomic, assign) DMProgressHUDMaskType maskType;

@property (nonatomic, assign, getter=isShowHUD) BOOL showHUD;

@property (nonatomic, copy) DMProgressHUDDismissCompletion dismissCompletion;

@property (nonatomic, copy) DMProgressHUDMaskTapHandle maskTapHandle;

@end

@implementation DMProgressHUD

#pragma mark - Life cycle
+ (instancetype)showProgressHUDAddedTo:(UIView *)view {

    return [self showProgressHUDAddedTo:view animation:DMProgressHUDAnimationDissolve maskType:DMProgressHUDMaskTypeNone];
}

+ (instancetype)showProgressHUDAddedTo:(UIView *)view animation:(DMProgressHUDAnimation)animation {

    return [self showProgressHUDAddedTo:view animation:animation maskType:DMProgressHUDMaskTypeNone];
}

+ (instancetype)showProgressHUDAddedTo:(UIView *)view maskType:(DMProgressHUDMaskType)maskType {

    return [self showProgressHUDAddedTo:view animation:DMProgressHUDAnimationDissolve maskType:maskType];
}

+ (instancetype)showProgressHUDAddedTo:(UIView *)view animation:(DMProgressHUDAnimation)animation maskType:(DMProgressHUDMaskType)maskType {

    return [self showProgressHUDAddedTo:view animation:animation maskType:maskType maskTapHandle:nil];
}

+ (instancetype)showProgressHUDAddedTo:(UIView *)view animation:(DMProgressHUDAnimation)animation maskType:(DMProgressHUDMaskType)maskType maskTapHandle:(DMProgressHUDMaskTapHandle)maskTapHandle {

    if (!view) return nil;
    
    DMProgressHUD *hud = [[self alloc] p_initWithView:view];
    hud.animation = animation;
    hud.maskType = maskType;
    hud.maskTapHandle = maskTapHandle;
    
    [view addSubview:hud];
    
    [hud p_showAnimation:animation];
    
    return hud;
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
    self.customWidth = 22;
    self.customHeight = 22;
    _insets = UIEdgeInsetsMake(20, 26, 20, 26);
    
    [self p_setUpConponents];
    [self p_configConstraints];
}

//Set up all of the conponents
- (void)p_setUpConponents {
    
    //Background view
    self.vBackground = [[UIView alloc] init];
    self.vBackground.translatesAutoresizingMaskIntoConstraints = NO;
    self.vBackground.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8];
    self.vBackground.layer.cornerRadius = 5;
    self.vBackground.layer.masksToBounds = YES;
    [self addSubview:self.vBackground];
    
    //Custom view
    _customView = nil;
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
    _layerCircle = [[CAShapeLayer alloc] init];
    _layerCircle.lineWidth = 3.0;
    _layerCircle.strokeColor = [[UIColor lightGrayColor] CGColor];
    _layerCircle.fillColor = [[UIColor clearColor] CGColor];
    
    _layerProgress = [[CAShapeLayer alloc] init];
    _layerProgress.lineWidth = 3.0;
    _layerProgress.strokeColor = [[UIColor whiteColor] CGColor];
    _layerProgress.fillColor = [[UIColor clearColor] CGColor];
    _layerProgress.lineCap = @"round";
    
    _labProgress = [[UILabel alloc] init];
    _labProgress.font = [UIFont systemFontOfSize:14.0];
    _labProgress.textAlignment = NSTextAlignmentCenter;
    [_labProgress sizeToFit];
    
    //default mode
    _customView = _indicator;
    self.loadingType = DMProgressHUDLoadingTypeIndicator;
}

- (void)drawRect:(CGRect)rect {
    
    CGPoint center = CGPointMake(_customWidth*0.5, _customHeight*0.5);
    CGFloat radius = _customWidth*0.5;
    
    //default cycle layer
    UIBezierPath *cyclePath = [UIBezierPath bezierPath];
    [cyclePath addArcWithCenter:center radius:radius startAngle:3*M_PI_2 endAngle:3*M_PI_2+2*M_PI*1 clockwise:YES];
    
    //progress detail layer
    UIBezierPath *detailPath = [UIBezierPath bezierPath];
    
    UIColor *color = _style == DMProgressHUDStyleLight ? [UIColor blackColor] : [UIColor whiteColor];
    
    if (_progressType == DMProgressHUDProgressTypeCircle) {
        
        _layerProgress.strokeColor = [color CGColor];
        _labProgress.textColor = color;
        
        [detailPath addArcWithCenter:center radius:radius startAngle:3*M_PI_2 endAngle:3*M_PI_2+2*M_PI*_progress clockwise:YES];
        
    } else if (_progressType == DMProgressHUDProgressTypeSector) {
        
        _layerCircle.lineWidth = 1;
        _layerProgress.lineWidth = 1;
        
        _layerCircle.strokeColor = [[color colorWithAlphaComponent:0.8] CGColor];
        _layerProgress.strokeColor = [color CGColor];
        _layerProgress.fillColor = [color CGColor];
        
        [detailPath moveToPoint:center];
        [detailPath addArcWithCenter:center radius:radius-2 startAngle:3*M_PI_2 endAngle:3*M_PI_2+2*M_PI*_progress clockwise:YES];
        
        _labProgress.hidden = YES;
    }
    
    //progress label
    self.layerCircle.path = [cyclePath CGPath];
    self.layerProgress.path = [detailPath CGPath];
    
    self.labProgress.frame = CGRectMake(0, 0, rect.size.width, rect.size.height*0.5);
    self.labProgress.center = center;
    self.labProgress.text = [NSString stringWithFormat:@"%.0f%%", self.progress*100];
    
    //    self.labProcess.hidden = self.process>0?NO:YES;
    
}

#pragma mark - Show
- (void)p_showAnimation:(DMProgressHUDAnimation)animation {
    
    _showHUD = YES;
    
    if (animation == DMProgressHUDAnimationDissolve) {
        self.alpha = 0;
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            
            self.alpha = 1;
            
        } completion:nil];
        
    } else if (animation == DMProgressHUDAnimationIncrement || animation == DMProgressHUDAnimationSpring) {
        
        //transform
        CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        transformAnimation.delegate = self;
        transformAnimation.duration = animationDuration/2;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.calculationMode = kCAAnimationCubicPaced;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)],
                      [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
        
        if (animation == DMProgressHUDAnimationSpring) {
            transformAnimation.duration = animationDuration+0.1;
            transformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)],
                          [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                          [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)],
                          [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
        }
        
        //opacity
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration = transformAnimation.duration;
        opacityAnimation.removedOnCompletion = NO;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.fromValue = @0;
        opacityAnimation.toValue = @1;
        
        [self.vBackground.layer addAnimation:transformAnimation forKey:nil];
        [self.layer addAnimation:opacityAnimation forKey:nil];
        
    }
    
}

#pragma mark - Dismiss
- (void)dismiss {
    
    [self dismissCompletion:nil];
}

- (void)dismissCompletion:(DMProgressHUDDismissCompletion)completion {

    _showHUD = NO;
    
    if (_animation == DMProgressHUDAnimationDissolve) {
        
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            
            self.alpha = 0;
        } completion:^(BOOL finished) {
            
            if (self.timer) {
                [self.timer invalidate];
                self.timer = nil;
            }
            
            [self removeFromSuperview];
            
            if (completion) {
                completion();
            }
            
        }];
    } else if (_animation == DMProgressHUDAnimationIncrement || _animation == DMProgressHUDAnimationSpring) {
        
        _dismissCompletion = completion;
        
        //transform
        CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        transformAnimation.delegate = self;
        transformAnimation.duration = animationDuration;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.calculationMode = kCAAnimationCubicPaced;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.values = @[
                      [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                      
                      [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 1.0)]
                      ];
        
        //opacity
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration = transformAnimation.duration;
        opacityAnimation.removedOnCompletion = NO;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.fromValue = @1;
        opacityAnimation.toValue = @0;
        
        [self.vBackground.layer addAnimation:transformAnimation forKey:nil];
        [self.layer addAnimation:opacityAnimation forKey:nil];
    }
}

- (void)dismissAfter:(NSTimeInterval)seconds {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self dismiss];
    });
}

- (void)dismissAfter:(NSTimeInterval)seconds completion:(DMProgressHUDDismissCompletion)completion {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self dismissCompletion:completion];
    });
}

#pragma mark - Constraints
- (void)p_configConstraints {
    
    if (_mode == DMProgressHUDModeLoading) {
        
        [_vBackground addSubview:_customView];
        [_vBackground addSubview:_label];
        [_vBackground removeConstraints:_vBackground.constraints];
        
        self.customWidth = 32;
        self.customHeight = self.customWidth;
        
        //custom
        [self p_configCustomViewContraints];
        
        //label
        [self p_configLabelConstraintsWithTopView:_customView];
        
        
        [self p_configBgViewWithTopView:_customView bottomView:_label];
        
    } else if (_mode == DMProgressHUDModeProgress) {
    
        self.customView = [[UIView alloc] init];
        [_customView.layer addSublayer:_layerCircle];
        [_customView.layer addSublayer:_layerProgress];
        [_customView.layer addSublayer:_labProgress.layer];
        [_vBackground addSubview:_customView];
        
        self.customWidth = 40;
        self.customHeight = self.customWidth;
        
        //custom
        [self p_configCustomViewContraints];
        
        //label
        [self p_configLabelConstraintsWithTopView:_customView];
        
        [self p_configBgViewWithTopView:_customView bottomView:_label];
    
    } else if (_mode == DMProgressHUDModeStatus || _mode == DMProgressHUDModeCustom) {
    
        [_vBackground addSubview:_customView];
        [_vBackground addSubview:_label];
        [_vBackground removeConstraints:_vBackground.constraints];
        [_customView removeConstraints:_customView.constraints];
        
        //custom
        [self p_configCustomViewContraints];
        
        //label
        [self p_configLabelConstraintsWithTopView:_customView];
        
        [self p_configBgViewWithTopView:_customView bottomView:_label];
    
    } else if (_mode == DMProgressHUDModeText) {
    
        //label
        [_vBackground addSubview:_label];
        [_customView removeFromSuperview];
        
        [self p_configLabelConstraintsWithTopView:nil];
        [self p_configBgViewWithTopView:_label bottomView:_label];
    }
}


//自定义视图(CustomView)约束
- (void)p_configCustomViewContraints {
    
    NSMutableArray *cusViewConstraints = [NSMutableArray new];
    
    //水平居中
    [cusViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    //大小
    [_customView addConstraint:[NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_customWidth]];
    [_customView addConstraint:[NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_customHeight]];
    
    [self addConstraints:cusViewConstraints];
}

//约束Label视图
- (void)p_configLabelConstraintsWithTopView:(UIView *)topView {
    
    NSMutableArray *cusViewConstraints = [NSMutableArray new];
    
    //居中
    [cusViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    //最大宽高
    [cusViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-2*margin]];
    [cusViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:-2*margin]];
    
    //上方View间距
    if (topView) {
        CGFloat marginTop = _label.text.length > 0 ? 10 : 0;
        [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1 constant:marginTop]];
    }
    
    [self addConstraints:cusViewConstraints];
}

//适应内容视图(_vBackground)
- (void)p_configBgViewWithTopView:(UIView *)topView bottomView:(UIView *)bottomView {
    
    //最大宽高约束
    NSMutableArray *bgConstraints = [NSMutableArray new];
    [bgConstraints addObject:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-2*margin]];
    [bgConstraints addObject:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:-2*margin]];
    [self addConstraints:bgConstraints];
    
    //获取比较宽的子视图
    UIView *maxWidthView = topView.bounds.size.width > bottomView.bounds.size.width ? topView : bottomView;
    //根据子视图自适应父视图
    [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeTop multiplier:1 constant:-_insets.top]];
    [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeBottom multiplier:1 constant:_insets.bottom]];
    [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:maxWidthView attribute:NSLayoutAttributeLeft multiplier:1 constant:-_insets.left]];
    [_vBackground addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:maxWidthView attribute:NSLayoutAttributeRight multiplier:1 constant:_insets.right]];
    

    //内容垂直居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_vBackground attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
}

+ (DMProgressHUD *)progressHUDForView:(UIView *)view {

    NSEnumerator *subViewsEnumerator = [view.subviews reverseObjectEnumerator];
    
    for (UIView *subView in subViewsEnumerator) {
        
        if ([subView isKindOfClass:self]) {
            
            return (DMProgressHUD *)subView;
        }
    }
    
    return nil;
}

#pragma mark - Setter
- (void)setMode:(DMProgressHUDMode)mode {
    
    _mode = mode;
    
    [self p_configConstraints];
}

- (void)setStatusType:(DMProgressHUDStatusType)statusType {

    _statusType = statusType;
    
    //default width&height
    self.customWidth = 22;
    self.customHeight = self.customWidth;
    
    _ivIcon = [[UIImageView alloc] init];
    NSString *lightStyle = _style == DMProgressHUDStyleLight ? @"black_" : @"";
    
    if (statusType == DMProgressHUDStatusTypeSuccess) {
        
        _ivIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"DMProgressImgs.bundle/progress_success_%@22x22_", lightStyle]];
        
    } else if (statusType == DMProgressHUDStatusTypeFail) {
    
        _ivIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"DMProgressImgs.bundle/progress_fail_%@24x24_", lightStyle]];
        
    } else if (statusType == DMProgressHUDStatusTypeWarning) {
        
        _ivIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"DMProgressImgs.bundle/progress_warning_%@32x28_", lightStyle]];
    }
    
    self.customView = _ivIcon;
    
    [self p_configConstraints];
}

- (void)setLoadingType:(DMProgressHUDLoadingType)loadingType {

    _loadingType = loadingType;
    
    if (_loadingType == DMProgressHUDLoadingTypeIndicator) {
        
        [_indicator startAnimating];
        self.customView = _indicator;
        
    } else if (_loadingType == DMProgressHUDLoadingTypeCircle) {
    
        NSString *lightStyle = _style == DMProgressHUDStyleLight ? @"black_" : @"";
        
        self.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"DMProgressImgs.bundle/progress_loading_%@32x32_", lightStyle]]];
        
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(p_showLoadingAnimation) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }
    
    [self p_configConstraints];
}


//custom view
- (void)setCustomView:(UIView *)view width:(CGFloat)width height:(CGFloat)height {

    if (_mode != DMProgressHUDModeCustom) return;
    
    self.customWidth = width;
    self.customHeight = height;
    
    self.customView = view;
    [self addSubview:_customView];
    
    [self p_configConstraints];
    
}

- (void)setCustomView:(UIView *)customView {
    
    [_customView removeFromSuperview];
    _customView = customView;
    _customView.frame = CGRectMake(0, 0, _customWidth, _customHeight);
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    
    //2%预显示
    //_progress = _progress > 0.02 ? _progress : 0.02;
    
    if (_mode == DMProgressHUDModeProgress) {
        
        [self setNeedsDisplay];
    }
    
}

//限制宽
- (void)setCustomWidth:(CGFloat)customWidth {
    
    CGFloat maxWidth = self.frame.size.width - 2*2*margin;
    _customWidth = customWidth > maxWidth ? maxWidth : customWidth;
}

//限制高
- (void)setCustomHeight:(CGFloat)customHeight {
    
    CGFloat maxHeight = self.frame.size.height - 2*2*margin;
    _customHeight  = customHeight > maxHeight ? maxHeight : customHeight;
}

//限制内边距
- (void)setInsets:(UIEdgeInsets)insets {

    _insets = insets;
    
    [self p_configConstraints];
}

- (void)setStyle:(DMProgressHUDStyle)style {

    _style = style;
    
    if (_style == DMProgressHUDStyleLight) {
    
        self.vBackground.backgroundColor = [UIColor colorWithRed:234/255.0 green:237/255.0 blue:239/255.0 alpha:0.95];
        self.label.textColor = [UIColor blackColor];
        
        if (_mode == DMProgressHUDModeLoading) {
            
            self.indicator.color = [UIColor blackColor];
            self.loadingType = self.loadingType;
            
        } else if (_mode == DMProgressHUDModeStatus) {
        
            self.statusType = self.statusType;
        }
    }
}

- (void)setMaskType:(DMProgressHUDMaskType)maskType {

    _maskType = maskType;
    
    self.userInteractionEnabled = maskType;
    
    if (maskType == DMProgressHUDMaskTypeClear) {
        
        self.backgroundColor = [UIColor clearColor];
        
    } else if (maskType == DMProgressHUDMaskTypeGray) {
    
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }
}


- (void)p_showLoadingAnimation {

    _customView.transform = CGAffineTransformRotate(_customView.transform, 0.0006);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"text"]) {
        
        [_label sizeToFit];
        
        [self p_configConstraints];
    }
}

#pragma mark - CAAnimation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    //clean up
    if (!self.isShowHUD) {
        
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        [self.vBackground.layer removeAllAnimations];
        [self removeFromSuperview];
        
        if (_dismissCompletion) {
            _dismissCompletion();
        }
    }
}

#pragma mark - touch delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if (self.maskTapHandle) {
        self.maskTapHandle(self);
    }
    
}


- (void)dealloc {

    [self.label removeObserver:self forKeyPath:@"text"];
    NSLog(@"%s", __func__);
}

@end
