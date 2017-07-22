//
//  NSString+Common.h
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/25/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

@interface NSString (Common)

-(BOOL)isBlank;
-(BOOL)contains:(NSString *)string;
-(NSArray *)splitOnChar:(char)ch;
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
-(NSString *)stringByStrippingWhitespace;
-(BOOL) stringIsValidEmail;

@end