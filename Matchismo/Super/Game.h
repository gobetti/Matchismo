//
//  Game.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/14/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Deck.h"

@interface Game : NSObject

// to be read by the view controller:
@property (nonatomic) NSInteger score;
@property (strong, nonatomic, readonly) NSMutableAttributedString *info;
@property (strong, nonatomic, readonly) NSMutableAttributedString *history;
@property (nonatomic, readonly) NSUInteger numberOfPresentCards;

- (instancetype)init __attribute__((unavailable ("One must use the designated initializer: initWithCardCount:")));
- (instancetype)initWithCardCount:(NSUInteger)count NS_DESIGNATED_INITIALIZER;

// The method below can optionally be overridden by subclasses:
- (NSUInteger)cardChoosingCost;

// The methods below should probably not be overridden by subclasses.
// If really necessary, then be sure to call super.
- (void)chooseCardAtIndex:(NSUInteger)index;
- (id)cardAtIndex:(NSUInteger)index;
- (void)removeCard:(Card *)card;
- (NSArray *)dealMoreCards:(NSUInteger)amount;
- (BOOL)isDeckEmpty;

- (void)updateInfoAddingPoints:(int)points append:(BOOL)append firstCard:(Card*)card1 secondCard:(Card*)card2 thirdCard:(Card*)card3;
- (void)updateInfo:(NSAttributedString *)toDisplay append:(BOOL)append;
- (void)updateHistory;

// The following (private) methods must be overridden by subclasses:
//- (NSUInteger)amountOfCardsToChoose;
//- (NSInteger)pointsWhenMatchedWithLastChosenCard:(Card*)card andScored:(NSInteger)matchScore;
//- (NSInteger)pointsWhenNoMatchesWithLastChosenCard:(Card*)card;

@end
