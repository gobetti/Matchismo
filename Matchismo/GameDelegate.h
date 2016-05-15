//
//  GameDelegate.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 5/12/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

#ifndef GameDelegate_h
#define GameDelegate_h

#import "Card.h"
#import "Deck.h"
#import "Game.h"

@protocol GameDelegate <NSObject>

- (Deck*)deck;

- (unsigned int)numberOfStartingCards;
- (unsigned int)cardChoosingCost;
- (unsigned int)amountOfCardsToChoose;
- (int)pointsWhenMatchedWithLastChosenCard:(id<Card>)card andScored:(int)matchScore inGame:(Game *)game;
- (int)pointsWhenNoMatchesWithLastChosenCard:(id<Card>)card inGame:(Game *)game;

@optional
- (void)willDealMoreCardsInGame:(Game *)game;

@end

#endif /* GameDelegate_h */
