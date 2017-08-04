//
//  CDActivitySpinner.m
//
//  Created by Stefan Goehler on 1/6/13.
//  Copyright (c) 2013-2017 Stefan Goehler. All rights reserved.
//

#import "CDActivitySpinner.h"
#import <QuartzCore/QuartzCore.h>
#include <math.h>       // modf

#define kAnimationCheckDelay 0.2
#define kAnimationDuration 1.0
#define kFadeInDuration .2

#define kProgressUndefined -1

@interface CDActivitySpinner () <CAAnimationDelegate>
@property (nonatomic, strong) CAShapeLayer* circleLayer;
@property (nonatomic, strong) CAShapeLayer* trackingLayer;
@property (nonatomic, assign) BOOL animationActivated;
@end

@implementation CDActivitySpinner

- (instancetype) init
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    if (self)
    {
        _progress = kProgressUndefined;
        [self setupView];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];
    }
    return self;
}

- (void) setupView
{
    self.backgroundColor = [UIColor clearColor];
    
    self.circleLayer = [CAShapeLayer layer];
    self.trackingLayer = [CAShapeLayer layer];
    self.openGap = kDefaultSpinnerGapSize;
    
    self.hidesWhenInactive = TRUE;
    [self adjustCircleToFrame];
    
    self.trackingLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.trackingLayer];
    
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.circleLayer];
    
    self.color = [UIColor whiteColor];
    self.trackingColor = nil;
}

- (void) setOpenGap:(CGFloat)openGap
{
    _openGap = MIN(1, MAX(openGap, 0));
}

- (void) setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self adjustCircleToFrame];
}

- (void) adjustCircleToFrame
{
    // Set up the shape of the circle
    if (self.lineWidth == 0)
    {
        self.circleLayer.lineWidth = MIN(3, self.frame.size.width / 15);
        self.trackingLayer.lineWidth = self.circleLayer.lineWidth;
    }
    else
    {
        self.circleLayer.lineWidth = self.lineWidth;
        self.trackingLayer.lineWidth = self.circleLayer.lineWidth;
    }
    
    NSInteger radius = self.frame.size.height / 2 - self.circleLayer.lineWidth / 2 + .5;
    // Make a circular shape
    self.circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2 * radius, 2 * radius)
                                                       cornerRadius:radius].CGPath;
    self.circleLayer.position = CGPointMake(self.frame.size.width  / 2 - radius,
                                            self.frame.size.height / 2 - radius);
    
    self.trackingLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2 * radius, 2 * radius)
                                                         cornerRadius:radius].CGPath;
    
    self.trackingLayer.position = CGPointMake(self.frame.size.width  / 2 - radius,
                                              self.frame.size.height / 2 - radius);
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self adjustCircleToFrame];
}

- (void) startAnimating
{
    if (![self.layer animationForKey:@"rotationAnimation"])
    {
        _progress = kProgressUndefined;
        self.animationActivated = TRUE;
        
        self.circleLayer.strokeStart = self.openGap;
        self.circleLayer.strokeEnd = 1;
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        // All animations should start at the same fraction of a second, so they all have the open end of the animation at the same angle
        
        double temp;
        // Animation start time - this only works this way because our duration is one full second
        rotationAnimation.timeOffset = modf(CACurrentMediaTime(), &temp);
        rotationAnimation.byValue = [NSNumber numberWithDouble:2 * M_PI];
        rotationAnimation.delegate = self;
        
        rotationAnimation.duration = kAnimationDuration;
        rotationAnimation.repeatCount = INFINITY;
        rotationAnimation.removedOnCompletion = FALSE;
        
        [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

        if (self.hidesWhenInactive || self.hidden)
            self.hidden = FALSE;
    }
}

- (void) stopAnimating
{
    self.animationActivated = FALSE;
    
    if ([self.layer animationForKey:@"rotationAnimation"])
    {
        [self.layer removeAnimationForKey:@"rotationAnimation"];
    }
    
    if (self.hidesWhenInactive)
    {
        self.hidden = TRUE;
    }
}

- (void) setColor:(UIColor *)color
{
    _color = color;
    self.circleLayer.strokeColor = color.CGColor;
}

- (void) setTrackingColor:(UIColor *)trackingColor
{
    _trackingColor = trackingColor;
    if (!trackingColor)
    {
        self.trackingLayer.hidden = TRUE;
    }
    else
    {
        self.trackingLayer.hidden = FALSE;
        self.trackingLayer.strokeColor = trackingColor.CGColor;
    }
}

- (void) setProgress:(float)progress
{
    [self setProgress:progress animated:TRUE];
}

- (void) setProgress:(float)progress animated:(BOOL)animated
{
    _progress = MIN(1, MAX(0, progress));
    
    // If it was used as activity indicator, stop the animation before
    if (self.animationActivated)
    {
        [self stopAnimating];
    }
    
    if (self.hidden)
        self.hidden = FALSE;
    
    [CATransaction begin];
    [CATransaction setDisableActions:!animated];
    self.circleLayer.strokeStart = 0;
    self.circleLayer.strokeEnd = progress;
    self.trackingLayer.strokeStart = progress;
    self.trackingLayer.strokeEnd = 1;
    [CATransaction commit];
}

- (void) setHidesWhenInactive:(BOOL)hidesWhenInactive
{
    _hidesWhenInactive = hidesWhenInactive;
    if (hidesWhenInactive && ![self.layer animationForKey:@"rotationAnimation"])
        self.hidden = TRUE;
}

- (BOOL) checkIfAnimationWasStopped
{
    // Have a look if spinner is in visible area
    if (!self.hidden && self.superview)
    {
        if (self.animationActivated && ![self.layer animationForKey:@"rotationAnimation"])
        {
            [self startAnimating];
            return FALSE;
        }
        return TRUE;
    }
    return TRUE;
}

- (void) didMoveToSuperview
{
    [super didMoveToSuperview];
    [self checkIfAnimationWasStopped];
}

- (void) removeFromSuperview
{
    [self stopAnimating];
    [super removeFromSuperview];
}

#pragma mark - CAAnimationDelegate
- (void) animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (self.hidesWhenInactive && !self.animationActivated && self.progress == kProgressUndefined)
        self.hidden = TRUE;
    
}


@end

