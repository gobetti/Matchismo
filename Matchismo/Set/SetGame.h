//
//  SetGame.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/9/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "GameDelegate.h"

@interface SetGame : NSObject<GameDelegate>

- (BOOL)isThereAnySetInGame:(Game *)game;

#pragma mark - GameDelegate protocol:

- (Deck*)deck;

- (unsigned int)numberOfStartingCards;
- (unsigned int)cardChoosingCost;
- (unsigned int)amountOfCardsToChoose;
- (int)pointsWhenMatchedWithLastChosenCard:(id<Card>)card andScored:(int)matchScore inGame:(Game *)game;
- (int)pointsWhenNoMatchesWithLastChosenCard:(id<Card>)card inGame:(Game *)game;

- (void)willDealMoreCardsInGame:(Game *)game;

@end