//
// UIScrollView+SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVPullToRefresh.h"

//fequalzro() from http://stackoverflow.com/a/1614761/184130
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

//static CGFloat const SVPullToRefreshViewHeight = 30;

@interface UIColor(NNKit)

@end

@implementation UIColor(NNKit)

+ (UIColor *)colorWithDecimalRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [[self class] colorWithDecimalRed:red green:green blue:blue alpha:1.0f];
}

+ (UIColor *)colorWithDecimalRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

+ (UIColor *)colorWithHex:(NSUInteger)color24 {
    CGFloat r = (color24 >> 16);
    CGFloat g = (color24 >> 8 & 0xFF);
    CGFloat b = (color24 & 0xFF);
    return [[self class] colorWithDecimalRed:r green:g blue:b alpha:1.0f];
}

+ (UIColor *)colorWithHex:(NSUInteger)color24 alpha:(CGFloat)alpha {
    CGFloat r = (color24 >> 16);
    CGFloat g = (color24 >> 8 & 0xFF);
    CGFloat b = (color24 & 0xFF);
    return [[self class] colorWithDecimalRed:r green:g blue:b alpha:alpha];
}

@end
@implementation CircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGFloat startAngle = -M_PI/3;
    CGFloat step = 11*M_PI/6 * self.progress;
    CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-3, startAngle, startAngle+step, 0);
    
    float radian = startAngle+step ;
    float x = self.bounds.size.width/2 + cos(radian)*(self.bounds.size.width/2-3);
    float y = self.bounds.size.height/2 + sin(radian)*(self.bounds.size.width/2-3);
    
    float arrowLength = 3;
    radian = radian + (float)M_PI_2;
    
    float leftAngle = radian - (float)(0.8*M_PI);
    float dx = cosf(leftAngle) * arrowLength;
    float dy = sinf(leftAngle) * arrowLength;
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + dx, y + dy);
    
    float rightAngle = radian + (float)(0.7*M_PI);
    float dx1 = cosf(rightAngle) * arrowLength;
    float dy1 = sinf(rightAngle) * arrowLength;
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + dx1, y + dy1);
    
    CGContextStrokePath(context);
}

@end

@interface SVPullToRefreshView ()

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);

@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *subtitleLabel;
@property (nonatomic, readwrite) SVPullToRefreshState state;

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *subtitles;
@property (nonatomic, strong) NSMutableArray *viewfor;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL showsPullToRefresh;
@property (nonatomic, assign) BOOL showsDateLabel;
@property(nonatomic, assign) BOOL isObserving;

//ishihama customize
@property (nonatomic, strong) UIActivityIndicatorView * indicator;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForLoading;
//- (void)setScrollViewContentInset:(UIEdgeInsets)insets;
- (void)resetScrollViewContentInsetWithAnimated:(BOOL)animated;
- (void)rotateArrow:(float)degrees hide:(BOOL)hide;

@end



#pragma mark - UIScrollView (SVPullToRefresh)
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (SVPullToRefresh)

@dynamic pullToRefreshView, showsPullToRefresh;


//ishihama customize
- (void)addPullToRefreshScrollHeight:(CGFloat)scrollHeight contentInsetTop:(CGFloat)top actionHandler:(void (^)(void))actionHandler{
    
    if(!self.pullToRefreshView) {
        SVPullToRefreshView *view = [[SVPullToRefreshView alloc] initWithFrame:CGRectMake(0, -scrollHeight, self.bounds.size.width, scrollHeight)];
        view.pullToRefreshActionHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalTopInset = top;
        self.pullToRefreshView = view;
        self.showsPullToRefresh = YES;
    }
}

- (void)changeScrollHeight:(CGFloat)scrollHeight contentInsetTop:(CGFloat)top{
    self.pullToRefreshView.frame = CGRectMake(0, -scrollHeight, self.bounds.size.width, scrollHeight);
    self.pullToRefreshView.originalTopInset = top;
}

- (void)triggerPullToRefresh {
    self.pullToRefreshView.state = SVPullToRefreshStateTriggered;
    [self.pullToRefreshView startAnimating];
}

- (void)setPullToRefreshView:(SVPullToRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"SVPullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"SVPullToRefreshView"];
}

- (SVPullToRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshView.hidden = !showsPullToRefresh;
    
    if(!showsPullToRefresh) {
        if (self.pullToRefreshView.isObserving) {
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];
            //[self.pullToRefreshView resetScrollViewContentInset];
            [self.pullToRefreshView resetScrollViewContentInsetWithAnimated:NO];
            self.pullToRefreshView.isObserving = NO;
        }
    }
    else {
        if (!self.pullToRefreshView.isObserving) {
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.pullToRefreshView.isObserving = YES;
        }
    }
}

- (BOOL)showsPullToRefresh {
    return !self.pullToRefreshView.hidden;
}

@end

#pragma mark - SVPullToRefresh
@implementation SVPullToRefreshView

// public properties
@synthesize pullToRefreshActionHandler, arrowColor, textColor, activityIndicatorViewStyle, lastUpdatedDate, dateFormatter;

@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize showsPullToRefresh = _showsPullToRefresh;
@synthesize arrow = _arrow;

@synthesize titleLabel = _titleLabel;
@synthesize dateLabel = _dateLabel;


- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {        
        self.state = SVPullToRefreshStateStopped;
        self.showsDateLabel = NO;
        self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.indicator.color = [UIColor colorWithHex:0xcccccc];
        [self addSubview:self.indicator];
    }

    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview { 
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsPullToRefresh) {
          if (self.isObserving) {
            //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
            [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            [scrollView removeObserver:self forKeyPath:@"frame"];
            self.isObserving = NO;
          }
        }
    }
}

- (void)layoutSubviews {
    self.arrow.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    self.indicator.center = self.arrow.center;
    
    for(id otherView in self.viewfor) {
        if([otherView isKindOfClass:[UIView class]])
            [otherView removeFromSuperview];
    }
          switch (self.state) {
            case SVPullToRefreshStateStopped:
                self.arrow.alpha = 1;
                [self.arrow.layer removeAllAnimations];
                [self rotateArrow:0 hide:NO isAnimated:YES];
                self.arrow.hidden = NO;
                self.indicator.hidden = YES;
                [self.indicator stopAnimating];
                break;
                
            case SVPullToRefreshStateTriggered:
                [self rotateArrow:(float)M_PI + 0.001 hide:NO isAnimated:YES]; //左回りにアニメーションさせるため
                self.indicator.hidden = YES;
                [self.indicator stopAnimating];
                self.arrow.hidden = NO;
                break;
                
            case SVPullToRefreshStateLoading:{
                self.indicator.hidden = NO;
                [self.indicator startAnimating];
                self.arrow.hidden = YES;
                [self rotateArrow:0 hide:NO isAnimated:NO];
            }
                break;
    }
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    //[self setScrollViewContentInset:currentInsets];
    [self setScrollViewContentInset:currentInsets animate:YES];
}
- (void)resetScrollViewContentInsetWithAnimated:(BOOL)animated {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    //[self setScrollViewContentInset:currentInsets];
    [self setScrollViewContentInset:currentInsets animate:NO];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height);
    //[self setScrollViewContentInset:currentInsets];
    [self setScrollViewContentInset:currentInsets animate:YES];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset animate:(BOOL)isAnimated {
    [UIView animateWithDuration:isAnimated ? 0.3 : 0
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {    
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"frame"])
        [self layoutSubviews];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state != SVPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = self.frame.origin.y-self.originalTopInset;
        
        if(!self.scrollView.isDragging && self.state == SVPullToRefreshStateTriggered)
            self.state = SVPullToRefreshStateLoading;
        else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateTriggered;
        else if(contentOffset.y >= scrollOffsetThreshold && self.state != SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateStopped;
    } else {
        CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
    }
}

#pragma mark - Getters

- (UIImageView *)arrow {
    if(!_arrow) {
		_arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_load_kuma"]];
		[self addSubview:_arrow];
    }
    return _arrow;
}

#pragma mark -

- (void)triggerRefresh {
    [self.scrollView triggerPullToRefresh];
}

- (void)startAnimating{
    if(fequalzero(self.scrollView.contentOffset.y)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.height) animated:YES];
        self.wasTriggeredByUser = NO;
    }
    else
        self.wasTriggeredByUser = YES;
    
    self.state = SVPullToRefreshStateLoading;
}

- (void)stopAnimating {
    self.state = SVPullToRefreshStateStopped;
    
    if(!self.wasTriggeredByUser && self.scrollView.contentOffset.y < -self.originalTopInset)
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:YES];
}

- (void)setState:(SVPullToRefreshState)newState {
    
    if(_state == newState)
        return;
    
    SVPullToRefreshState previousState = _state;
    _state = newState;
    
    [self setNeedsLayout];
    
    switch (newState) {
        case SVPullToRefreshStateStopped:
            //[self resetScrollViewContentInsetWithAnimated:YES]
            [self resetScrollViewContentInset];
            break;
            
        case SVPullToRefreshStateTriggered:
            break;
            
        case SVPullToRefreshStateLoading:
            [self setScrollViewContentInsetForLoading];
            
            if(previousState == SVPullToRefreshStateTriggered && pullToRefreshActionHandler)
                pullToRefreshActionHandler();
            
            break;
    }
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide {
    [self rotateArrow:degrees hide:hide isAnimated:YES];
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide isAnimated:(BOOL)isAnimated{
    [UIView animateWithDuration:isAnimated ? 0.2 : 0.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
        self.arrow.layer.opacity = !hide;
    } completion:NULL];
}

@end
