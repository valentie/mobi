//
//  GSApiResponseObjectItem.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSApiResponseObjectItem.h"

@implementation GSApiResponseObjectItem

@synthesize responseData;
@synthesize statusCode, statusErrorMessage, statusMessage;

-(instancetype)initWithNSData:(NSData *)data{
    self = [super init];
    if(self)
    {
        
        //self.data = dict;
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        
        if (localError != nil) {
            statusCode = 1;
            statusMessage = localError.localizedDescription;
            statusErrorMessage = localError.localizedDescription;
        } else {
            NSDictionary *jsonResponseStatus = [parsedObject valueForKey:@"responseStatus"];
            responseData = [parsedObject valueForKey:@"responseData"];
            statusCode = [[jsonResponseStatus valueForKey:@"statusCode"] intValue];
            statusMessage = [jsonResponseStatus valueForKey:@"statusMessage"];
            statusErrorMessage = [jsonResponseStatus valueForKey:@"statusErrorMessage"];
        }
        
    }
    return self;
}

@end