//
//  NSString+Common.m
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/25/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)
-(BOOL)isBlank {
    if([[self stringByStrippingWhitespace] isEqualToString:@""])
        return YES;
    return NO;
}

-(BOOL)contains:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

-(NSString *)stringByStrippingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSArray *)splitOnChar:(char)ch {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    int start = 0;
    for(int i=0; i<[self length]; i++) {
        
        BOOL isAtSplitChar = [self characterAtIndex:i] == ch;
        BOOL isAtEnd = i == [self length] - 1;
        
        if(isAtSplitChar || isAtEnd) {
            //take the substring &amp; add it to the array
            NSRange range;
            range.location = start;
            range.length = i - start + 1;
            
            if(isAtSplitChar)
                range.length -= 1;
            
            [results addObject:[self substringWithRange:range]];
            start = i + 1;
        }
        
        //handle the case where the last character was the split char.  we need an empty trailing element in the array.
        if(isAtEnd && isAtSplitChar)
            [results addObject:@""];
    }
    
    return results;
}

-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to {
    NSString *rightPart = [self substringFromIndex:from];
    return [rightPart substringToIndex:to-from];
}


-(BOOL) stringIsValidEmail
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end