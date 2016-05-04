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
@property (nonatomic, strong) NSMutableArray *otherCards;
@property (strong, nonatomic) PlayingCardDeck *deck; // will hold to this deck
@end

@implementation PlayingCardGame

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int MATCH2_BONUS = 2;
static const int COST_TO_CHOOSE = 1;

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

- (PlayingCard *)lastCard
{
    return [self.cards lastObject];
}

- (NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (NSMutableArray *)otherCards
{
    if (!_otherCards) _otherCards = [[NSMutableArray alloc] init];
    return _otherCards;
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

- (void)chooseCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    int points = 0;
    
    // deselects card (flips it back) if it was already selected:
    if (card.isChosen)
    {
        card.chosen = NO;
        return; // then the function ends here!
    }
    
    // the chosen card was not chosen before, moving on...
    BOOL enoughChosenCards = NO;
    for (Card *otherCard in self.cards)
    {
        // look for chosen and unmatched cards:
        if (otherCard.isChosen && !otherCard.isMatched)
        {
            [self.otherCards addObject:otherCard]; // save them
        }
        // break the loop once we have the other two chosen cards (mode=3) or the one other chosen card (mode = 2)
        if ((self.mode == 2 && [self.otherCards count] == 1) ||
            [self.otherCards count] == 2)
        {
            enoughChosenCards = YES;
            break;
        }
    }
    
    card.chosen = YES; // show the front of the card
    
    if (!enoughChosenCards) {
        return;
    }
    
    // so, the user has selected enough cards to make a set. Let's take some action!
    
    Card *otherCard = [self.otherCards firstObject];
    Card *anotherCard; // will be nil in 2-card mode, or if only two cards were chosen in 3-card mode:
    if (self.mode == 3) {
        anotherCard = [self.otherCards lastObject];
    }
    // not checking the cards above for nil, we already know that otherCards has enough cards
    
    int matchScore = [card match:self.otherCards]; // "card" is compared against all the others
    // P.S.: even in 3-card mode, only "card" is compared to the others, because the first 2 can be freely chosen by the player, so there's no point on giving points for their combination
    
    int matchScore1 = 0, matchScore2 = 0; // might be used for 1 mismatch + 1 match case in 3-card mode
    if ((self.mode == 3 && (matchScore == 2 || matchScore == 5 || matchScore == 8)) || // no mismatches in 3-card mode
        (self.mode == 2 && (matchScore == 4 || matchScore == 1))) // no mismatches in 2-card mode
    {
        points = matchScore*MATCH_BONUS;
        for (Card *everyCard in self.otherCards)
        {
            everyCard.matched = YES;
        }
        card.matched = YES;
    }
    else if (matchScore && self.mode == 3) // 1 mismatch + 1 match in 3-card mode
    {
        card.matched = YES;
        // look individually for the mismatching card
        matchScore1 = [card match:@[anotherCard]];
        matchScore2 = [card match:@[otherCard]];
        points = (matchScore1+matchScore2)*MATCH2_BONUS - MISMATCH_PENALTY;
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
    }
    else if (!matchScore) // no matches
    {
        // flip back all but the last card:
        for (Card *everyCard in self.otherCards)
        {
            everyCard.chosen = NO;
        }
        if (self.mode == 2)
        {
            points = -MISMATCH_PENALTY;
        }
        else // 3-card mode
        {
            points = -2*MISMATCH_PENALTY; // double penalty, too dumb! :)
        }
    }
    
    self.score += points;
    if (!matchScore1 && !matchScore2) // set default info except for 1 mismatch + 1 match case
    {
        [self updateInfoAddingPoints:points append:NO firstCard:card secondCard:otherCard thirdCard:anotherCard];
    }
    [self updateHistory];
    self.score -= COST_TO_CHOOSE;
    [self.otherCards removeAllObjects]; // won't be used anymore -> cleared for next play
}
@end