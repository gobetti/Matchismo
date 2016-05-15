//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/1/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "GameDelegate.h"

@interface PlayingCardGame : NSObject <GameDelegate>

@property (nonatomic, readonly) unsigned int mode;

- (void)changeMode;

#pragma mark - GameDelegate protocol:

- (Deck*)deck;

- (unsigned int)numberOfStartingCards;
- (unsigned int)cardChoosingCost;
- (unsigned int)amountOfCardsToChoose;
- (int)pointsWhenMatchedWithLastChosenCard:(id<Card>)card andScored:(int)matchScore inGame:(Game *)game;
- (int)pointsWhenNoMatchesWithLastChosenCard:(id<Card>)card inGame:(Game *)game;

@end