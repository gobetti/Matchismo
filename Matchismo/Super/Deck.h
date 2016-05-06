//
//  Deck.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/1/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Card.h"

@interface Deck : NSObject

- (void)addCard:(Card *)card;

- (id)drawRandomCard;
@property (nonatomic, readonly) BOOL isEmpty;

@end
