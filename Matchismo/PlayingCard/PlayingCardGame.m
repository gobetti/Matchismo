//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/1/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "PlayingCardGame.h"
#import "PlayingCardDeck.h"

@interface PlayingCardGame()
@property (nonatomic, readwrite) NSUInteger mode;
// private:
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableSet *chosenCards;
@property (strong, nonatomic) PlayingCardDeck *deck; // will hold to this deck
@end

@implementation PlayingCardGame

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int MATCH2_BONUS = 2;

- (instancetype)initWithCardCount:(NSUInteger)count {
    if (!(self = [super initWithCardCount:count])) {
        return nil;
    }
    self.mode = 2; // default = 2-card
    return self;
}

- (PlayingCardDeck *)deck
{
    if (!_deck) _deck = [[PlayingCardDeck alloc] init];
    return _deck;
}

- (NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (NSMutableSet *)chosenCards
{
    if (!_chosenCards) _chosenCards = [[NSMutableSet alloc] init];
    return _chosenCards;
}

- (void)changeMode
{
    if (self.mode == 2) {
        self.mode = 3;
    }
    else {
        self.mode = 2;
    }
}

- (NSUInteger)amountOfCardsToChoose {
    return self.mode;
}

- (NSInteger)pointsWhenMatchedWithLastChosenCard:(id<Card>)card andScored:(NSInteger)matchScore {
    NSMutableArray *mutableCards = [NSMutableArray arrayWithArray:[self.chosenCards allObjects]];
    [mutableCards removeObject:card];
    id<Card> otherCard = [mutableCards firstObject];
    id<Card> anotherCard = [mutableCards lastObject];
    int matchScore1 = 0, matchScore2 = 0; // might be used for 1 mismatch + 1 match case in 3-card mode
    
    // testing first the case when no mismatches were found:
    if (self.mode == 2 ||
        (self.mode == 3 && (matchScore == 2 || matchScore == 5 || matchScore == 8))) // no mismatches in 3-card mode
    {
        for (id<Card> everyCard in self.chosenCards) {
            everyCard.matched = YES;
        }
        
        return matchScore*MATCH_BONUS;
    }
    else // in 3-card mode, it could be 1 mismatch + 1 match
    {
        card.matched = YES;
        // look individually for the mismatching card
        matchScore1 = [card match:@[anotherCard]];
        matchScore2 = [card match:@[otherCard]];
        if (!matchScore1) // anotherCard doesn't match
        {
            otherCard.matched = YES;
            anotherCard.chosen = NO;
            [self updateInfoAddingPoints:(-MISMATCH_PENALTY) append:NO firstCard:card secondCard:anotherCard thirdCard:nil];
            [self updateInfoAddingPoints:matchScore2*MATCH2_BONUS append:YES firstCard:card secondCard:otherCard thirdCard:nil];
        }
        else if(!matchScore2) // otherCard doesn't match
        {
            anotherCard.matched = YES;
            otherCard.chosen = NO;
            [self updateInfoAddingPoints:(-MISMATCH_PENALTY) append:NO firstCard:card secondCard:otherCard thirdCard:nil];
            [self updateInfoAddingPoints:matchScore1*MATCH2_BONUS append:YES firstCard:card secondCard:anotherCard thirdCard:nil];
        }
        
        return (matchScore1+matchScore2) * MATCH2_BONUS - MISMATCH_PENALTY;
    }
}

- (NSInteger)pointsWhenNoMatchesWithLastChosenCard:(id<Card>)card {
    NSMutableArray *mutableCards = [NSMutableArray arrayWithArray:[self.chosenCards allObjects]];
    [mutableCards removeObject:card];
    
    // flip back all but the last card chosen:
    for (id<Card> everyCard in mutableCards)
    {
        everyCard.chosen = NO;
    }
    
    if (self.mode == 2)
    {
        return -MISMATCH_PENALTY;
    }
    else // 3-card mode
    {
        return -2 * MISMATCH_PENALTY; // double penalty, too dumb! :)
    }
}

@end