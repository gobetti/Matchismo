//
//  NSException+NotImplemented.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 5/6/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

#import "NSException+NotImplemented.h"

@implementation NSException (NotImplemented)

+ (NSException *)notImplementedException
{
    return [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end