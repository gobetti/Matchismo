//
//  Game.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/14/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Game.h"
#import "NSException+NotImplemented.h"

@interface Game()
@property (strong, nonatomic, readwrite) NSMutableAttributedString *info;
@property (strong, nonatomic, readwrite) NSMutableAttributedString *history; // should be strong for segue
// private:
@property (strong, nonatomic) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableSet *chosenCards;
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

- (void)removeCard:(id<Card>)card
{
    [self.cards removeObject:card];
}

- (BOOL)isDeckEmpty
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
            id<Card> card = [self.deck drawRandomCard];
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
    id<Card> card = [self cardAtIndex:index];
    // deselects card (flips it back) if it was already selected:
    if (card.isChosen)
    {
        card.chosen = NO;
        [self.chosenCards removeObject:card];
        return; // then the function ends here!
    }
    
    // the chosen card was not chosen before, moving on...
    card.chosen = YES; // show the front of the card
    [self.chosenCards addObject:card];
    
    if ([self.chosenCards count] != self.amountOfCardsToChoose) {
        return;
    }
    
    // so, the user has selected enough cards to make a set. Let's take some action!
    NSMutableArray *otherCards = [NSMutableArray arrayWithArray:[self.chosenCards allObjects]];
    [otherCards removeObject:card]; // all except the card that was chosen for last
    int matchScore = [card match:otherCards]; // "card" is compared against all the others
    
    int points = 0;
    if (matchScore) {
        points = [self pointsWhenMatchedWithLastChosenCard:card andScored:matchScore];
    }
    else {
        points = [self pointsWhenNoMatchesWithLastChosenCard:card];
    }
    
    self.score += points;
    
    id<Card> otherCard = [otherCards firstObject];
    id<Card> anotherCard = nil;
    if ([otherCards count] == 2) { // always true for the Set game
        anotherCard = [otherCards lastObject];
    }
    [self updateInfoAddingPoints:points append:NO firstCard:card secondCard:otherCard thirdCard:anotherCard];
    
    [self updateHistory];
    self.score -= self.cardChoosingCost;
    
    // remove card from the chosenCards if it is not chosen anymore, or if it was matched:
    NSMutableArray *notChosenAnymore = [[NSMutableArray alloc] init];
    for (id<Card> chosenCard in self.chosenCards) {
        if (!chosenCard.isChosen || chosenCard.isMatched) {
            [notChosenAnymore addObject:chosenCard];
        }
    }
    for (id<Card> unchosenCard in notChosenAnymore) {
        [self.chosenCards removeObject:unchosenCard];
    }
}

- (NSUInteger)cardChoosingCost {
    return 1;
}

// this method returns 0..amount cards
- (NSArray *)dealMoreCards:(NSUInteger)amount
{
    NSMutableArray *newCards = [[NSMutableArray alloc] init];
    for (int i = 0; i <= amount - 1; i++)
    {
        id<Card> card = [self.deck drawRandomCard];
        if(card) {
            [self.cards addObject:card];
            [newCards addObject:card];
        }
    }
    return newCards;
}

- (void)updateInfoAddingPoints:(int)points append:(BOOL)append firstCard:(id<Card>)card1 secondCard:(id<Card>)card2 thirdCard:(id<Card>)card3
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

#pragma mark - Abstract methods: implementation required on subclasses

- (NSUInteger)amountOfCardsToChoose
{
    @throw [NSException notImplementedException];
}

- (NSInteger)pointsWhenMatchedWithLastChosenCard:(id<Card>)card andScored:(NSInteger)matchScore
{
    @throw [NSException notImplementedException];
}

- (NSInteger)pointsWhenNoMatchesWithLastChosenCard:(id<Card>)card
{
    @throw [NSException notImplementedException];
}

@end
