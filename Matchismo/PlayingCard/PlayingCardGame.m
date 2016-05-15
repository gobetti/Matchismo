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
@property (nonatomic, readwrite) unsigned int mode;
@end

@implementation PlayingCardGame

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int MATCH2_BONUS = 2;

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    self.mode = 2; // default = 2-card
    return self;
}

- (Deck *)deck
{
    return [[PlayingCardDeck alloc] init];
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

- (unsigned int)numberOfStartingCards {
    return 40;
}

- (unsigned int)cardChoosingCost {
    return 1;
}

- (unsigned int)amountOfCardsToChoose {
    return self.mode;
}

- (int)pointsWhenMatchedWithLastChosenCard:(id<Card>)card andScored:(int)matchScore inGame:(Game *)game
{
    NSMutableArray *mutableCards = [NSMutableArray arrayWithArray:[game.chosenCards allObjects]];
    [mutableCards removeObject:card];
    id<Card> otherCard = [mutableCards firstObject];
    id<Card> anotherCard = [mutableCards lastObject];
    int matchScore1 = 0, matchScore2 = 0; // might be used for 1 mismatch + 1 match case in 3-card mode
    
    // testing first the case when no mismatches were found:
    if (self.mode == 2 ||
        (self.mode == 3 && (matchScore == 2 || matchScore == 5 || matchScore == 8))) // no mismatches in 3-card mode
    {
        for (id<Card> everyCard in game.chosenCards) {
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
        }
        else if(!matchScore2) // otherCard doesn't match
        {
            anotherCard.matched = YES;
            otherCard.chosen = NO;
        }
        
        return (matchScore1+matchScore2) * MATCH2_BONUS - MISMATCH_PENALTY;
    }
}

- (int)pointsWhenNoMatchesWithLastChosenCard:(id<Card>)card inGame:(Game *)game
{
    // flip back all but the last chosen card:
    for (id<Card> everyCard in game.chosenCards)
    {
        if (![everyCard isEqual:card]) {
            everyCard.chosen = NO;
        }
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