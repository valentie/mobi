//
//  UIScrollView+DZNSegmentedControl.h
//  DZNSegmentedControl
//  https://github.com/dzenbot/DZNSegmentedControl
//
//  Created by Rene van der Kooi on 2015-08-10.
//  Copyright (c) 2014 Mindzone Company Limited. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>

@class DZNSegmentedControl;

@interface UIScrollView (DZNSegmentedControl)

@property (nonatomic, weak) DZNSegmentedControl *segmentedControl;

@end
