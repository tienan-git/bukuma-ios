//
// UIScrollView+SVPullToRefresh.h
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>


@class SVPullToRefreshView;

@interface CircleView : UIView

@property (nonatomic, assign) float progress;

@end


@interface UIScrollView (SVPullToRefresh)

- (void)addPullToRefreshScrollHeight:(CGFloat)scrollHeight
                     contentInsetTop:(CGFloat)top
                       actionHandler:(void (^)(void))actionHandler;//customize
- (void)changeScrollHeight:(CGFloat)scrollHeight contentInsetTop:(CGFloat)top;
- (void)triggerPullToRefresh;

@property (nonatomic, strong, readonly) SVPullToRefreshView *pullToRefreshView;
@property (nonatomic, assign) BOOL showsPullToRefresh;

@end


enum {
    SVPullToRefreshStateStopped = 0,
    SVPullToRefreshStateTriggered,
    SVPullToRefreshStateLoading,
    SVPullToRefreshStateAll = 10
};

typedef NSUInteger SVPullToRefreshState;

@interface SVPullToRefreshView : UIView

@property (nonatomic, strong) UIColor *arrowColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;
@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@property (nonatomic, readwrite) CGFloat originalTopInset;

@property (nonatomic, readonly) SVPullToRefreshState state;

//- (void)setTitle:(NSString *)title for:(SVPullToRefreshState)state;
//- (void)setSubtitle:(NSString *)subtitle for:(SVPullToRefreshState)state;
//- (void)setCustomView:(UIView *)view for:(SVPullToRefreshState)state;

- (void)startAnimating;
- (void)stopAnimating;


// deprecated; use setSubtitle:for: instead
@property (nonatomic, strong, readonly) UILabel *dateLabel DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSDate *lastUpdatedDate DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSDateFormatter *dateFormatter DEPRECATED_ATTRIBUTE;

// deprecated; use [self.scrollView triggerPullToRefresh] instead
- (void)triggerRefresh DEPRECATED_ATTRIBUTE;

@end
