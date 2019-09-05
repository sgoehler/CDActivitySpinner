//
//  CDActivitySpinner.h
//
//  Created by Stefan Goehler on 1/6/13.
//  Copyright (c) 2013-2019 Stefan Goehler. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultSpinnerGapSize 0.08

/// Shows either a spinning activity indicator or a progress view
@interface CDActivitySpinner : UIView

/// Set progress from 0..1
@property (nonatomic, assign) float progress;

/// Automatically hide when stopped; true by default
@property (nonatomic, assign) BOOL hidesWhenInactive;

/// Activity indicator color
@property (nonatomic, strong) UIColor* color;

/// If set, animated circle is upon a full circle
@property (nonatomic, strong) UIColor* trackingColor;

/// How wide is the circle gap in the activity indicator? 0..1
@property (nonatomic, assign) CGFloat openGap;

@property (nonatomic, assign) CGFloat lineWidth;

- (void) setProgress:(float)progress animated:(BOOL)animated;

/// Start activity animation
- (void) startAnimating;

/// Stop activity animation
- (void) stopAnimating;

@end
