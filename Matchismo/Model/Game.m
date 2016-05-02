//
//  Game.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/14/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Game.h"

@interface Game()
@property (strong, nonatomic, readwrite) NSMutableAttributedString *info;
@property (strong, nonatomic, readwrite) NSMutableAttributedString *history; // should be strong for segue
// private:
@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) Deck *deck;
@end

@implementation Game

- (NSUInteger)numberOfPresentCards {
    return [self.cards count];
}

- (NSMutableAttributedString *)history
{
    if (!_history) _history = [[NSMutableAttributedString alloc] init];
    return _history;
}

- (NSMutableAttributedString *)info
{
    if (!_info) _info = [[NSMutableAttributedString alloc] init];
    return _info;
}

- (void)removeCard:(Card *)card
{
    [self.cards removeObject:card];
}

- (BOOL) isDeckEmpty
{
    return self.deck.isEmpty;
}

- (instancetype)initWithCardCount:(NSUInteger)count
{
    // start the initializer letting the superclass initialize itself first (and check for failure)
    self = [super init];
    
    if (self)
    {
        for (int i = 0; i < count; i++)
        {
            Card *card;
            card = [self.deck drawRandomCard];
            if (card)
            { [self.cards addObject:card]; }
            else
            {
                self = nil;
                break;
            }
        }
    }
    
    return self;
}

- (id)cardAtIndex:(NSUInteger)index
{
    // verifies if index is not out of bounds
    return (index<[self.cards count]) ? self.cards[index] : nil;
}

- (void)chooseCardAtIndex:(NSUInteger)index
{
    // no base implementation
}

- (void)updateInfoAddingPoints:(int)points append:(BOOL)append firstCard:(Card*)card1 secondCard:(Card*)card2 thirdCard:(Card*)card3
{
    NSString *string;
    NSMutableAttributedString *toDisplay;
    if (points>0)
    {
        string = [NSString stringWithFormat:@"(+%d) ", points];
    }
    else
    {
        string = [NSString stringWithFormat:@"(%d) ", points];
    }
    toDisplay = [[NSMutableAttributedString alloc] initWithString:string];
    [toDisplay appendAttributedString:card1.contents];
    
    if (card3) // always nil in 2-card mode
    {
        string = @", ";
        [toDisplay appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        [toDisplay appendAttributedString:card3.contents];
    }
    // assuming card2 is never nil:
    string = @" and ";
    [toDisplay appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
    [toDisplay appendAttributedString:card2.contents];
    
    // final point
    string = @".";
    [toDisplay appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
    
    [self updateInfo:toDisplay append:append];
}

- (void)updateInfo:(NSAttributedString *)toDisplay append:(BOOL)append
{
    if(append) {
        [self.info appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [self.info appendAttributedString:toDisplay];
    }
    else { [self.info setAttributedString:toDisplay]; }
}

- (void)updateHistory
{
    [self.history appendAttributedString:self.info];
    NSString *linebreak = @"\n";
    [self.history appendAttributedString:[[NSAttributedString alloc] initWithString:linebreak]];
}

@end
