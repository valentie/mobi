//
//  GSMasterCellObjectItem.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSMasterCellObjectItem : NSObject

@property (nonatomic,strong) NSDictionary *data;

-(instancetype)initWithDict:(NSDictionary *)dict;

@end
