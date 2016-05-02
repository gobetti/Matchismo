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

// designated initializer
- (instancetype)initWithCardCount:(NSUInteger)count;

- (void)chooseCardAtIndex:(NSUInteger)index;
- (id)cardAtIndex:(NSUInteger)index;
- (void)removeCard:(Card *)card;
- (BOOL)isDeckEmpty;

- (void)updateInfoAddingPoints:(int)points append:(BOOL)append firstCard:(Card*)card1 secondCard:(Card*)card2 thirdCard:(Card*)card3;
- (void)updateInfo:(NSAttributedString *)toDisplay append:(BOOL)append;
- (void)updateHistory;

@end
