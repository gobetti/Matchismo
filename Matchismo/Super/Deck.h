//
//  Deck.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/1/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Card.h"

@interface Deck : NSObject

// The methods below should probably not be overridden by subclasses.
// If really necessary, then be sure to call super.
- (void)addCard:(Card *)card;
- (id)drawRandomCard;
- (BOOL)isEmpty;

@end
