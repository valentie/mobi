//
//  GSMasterCellObjectItem.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSMasterCellObjectItem.h"

@implementation GSMasterCellObjectItem

@synthesize data;

-(instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if(self)
    {
        self.data = dict;
    }
    return self;
}

@end