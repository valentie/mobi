//
//  GSCollectionHeaderView.m
//  MOBITV
//
//  Created by Renee van der Kooi on 11/18/2558 BE.
//  Copyright © 2558 Mindzone Company Limited. All rights reserved.
//

#import "GSCollectionHeaderView.h"

@implementation GSCollectionHeaderView

@synthesize title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        title =[[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width, self.frame.size.height)];
        title.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        title.textColor = [UIColor darkGrayColor];
        title.font = [UIFont boldSystemFontOfSize:15.0];
        [self addSubview:title];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor] );
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    
    CGContextRef context2 = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context2, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context2, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextSetStrokeColorWithColor(context2, [[UIColor grayColor] CGColor] );
    CGContextSetLineWidth(context2, 1.0);
    CGContextStrokePath(context2);
}

@end
