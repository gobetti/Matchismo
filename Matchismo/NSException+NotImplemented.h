//
//  NotImplementedException.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 5/6/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>

// import this header into all super classes
// and call this method in all abstract methods
// (those without a "super" definition and that must be implemented by subclasses)
@interface NSException (NotImplemented)

+ (NSException *)notImplementedException;

@end