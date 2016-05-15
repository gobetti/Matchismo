//
//  Game.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/14/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Deck.h"

@protocol GameDelegate; // forward declaration

@interface Game : NSObject

// to be read by the game delegate:
@property (nonatomic, strong, readonly) NSMutableArray *cards;
@property (nonatomic, strong, readonly) NSMutableSet *chosenCards;

// to be read by the view controller:
@property (nonatomic) NSInteger score;
@property (strong, nonatomic, readonly) NSMutableAttributedString *info;
@property (strong, nonatomic, readonly) NSMutableAttributedString *history;

- (instancetype)init __attribute__((unavailable ("One must use the designated initializer: initWithDelegate:")));
- (instancetype)initWithDelegate:(id<GameDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (unsigned int)numberOfStartingCards;
- (void)removeCard:(id<Card>)card;
- (NSUInteger)numberOfPresentCards;

- (void)chooseCardAtIndex:(NSUInteger)index;
- (id<Card>)cardAtIndex:(NSUInteger)index;
- (NSArray *)dealMoreCards:(NSUInteger)amount;
- (BOOL)isDeckEmpty;

- (void)updateInfo:(NSAttributedString *)toDisplay append:(BOOL)append;
- (void)updateInfoAddingPoints:(int)points append:(BOOL)append firstCard:(id<Card>)card1 secondCard:(id<Card>)card2 thirdCard:(id<Card>)card3;
- (void)updateHistory;
- (void)gameOver;

@end
