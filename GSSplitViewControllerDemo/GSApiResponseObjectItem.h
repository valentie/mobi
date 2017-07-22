//
//  GSApiResponseObjectItem.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface GSApiResponseObjectItem : NSObject

@property (nonatomic,strong) NSDictionary *responseData;
@property (nonatomic,readonly) int statusCode;
@property (nonatomic,strong) NSString *statusMessage;
@property (nonatomic,strong) NSString *statusErrorMessage;


-(instancetype)initWithNSData:(NSData *)data;

@end
