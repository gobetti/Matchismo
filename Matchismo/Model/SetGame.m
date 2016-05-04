//
//  SetGame.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/9/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "SetGame.h"
#import "SetDeck.h"

@interface SetGame()
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *otherCards;
@property (strong, nonatomic) SetDeck *deck; // will hold to this deck
@end

@implementation SetGame

static const int COST_TO_CHOOSE = 1;

- (NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (NSMutableArray *)otherCards
{
    if (!_otherCards) _otherCards = [NSMutableArray arrayWithCapacity:2];
    return _otherCards;
}

- (SetDeck *)deck
{
    if (!_deck) _deck = [[SetDeck alloc] init];
    return _deck;
}

- (void)chooseCardAtIndex:(NSUInteger)index
{
    SetCard *card = [self cardAtIndex:index];
    int points;
    
    // deselects card (flips it back) if it was already selected:
    if (card.isChosen)
    {
        card.chosen = NO;
        return; // then the function ends here!
    }
    
    // the chosen card was not chosen before, moving on...
    BOOL enoughChosenCards = NO;
    for (SetCard *otherCard in self.cards)
    {
        // look for chosen and unmatched cards:
        if (otherCard.isChosen && !otherCard.isMatched)
        {
            [self.otherCards addObject:otherCard]; // save them
        }
        // break the loop once we have the other two chosen cards
        if ([self.otherCards count] == 2)
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
    SetCard *otherCard = [self.otherCards firstObject];
    SetCard *anotherCard = [self.otherCards lastObject];
    // not checking the cards above for nil, we already know that otherCards has enough cards
    
    int matchScore = [card match:self.otherCards]; // "card" is compared against all the others
    if (matchScore) // we have a set
    {
        points = 21 - self.numberOfPresentCards;
        otherCard.matched = YES;
        anotherCard.matched = YES;
        card.matched = YES;
    }
    else
    {
        otherCard.chosen = NO;
        anotherCard.chosen = NO;
        card.chosen = NO;
        points = -self.numberOfPresentCards;
    }
    
    self.score += points;
    [self updateInfoAddingPoints:points append:NO firstCard:card secondCard:otherCard thirdCard:anotherCard];
    [self updateHistory];
    self.score -= COST_TO_CHOOSE;
    [self.otherCards removeAllObjects]; // won't be used anymore -> cleared for next play
}

- (BOOL)isThereAnySet
{
    NSMutableArray *currentSet = [[NSMutableArray alloc] init];
    // won't use for (... in ...) to avoid repetitions of combinations
    for (NSUInteger firstCardIndex = 0; firstCardIndex <= self.numberOfPresentCards-3; firstCardIndex++)
    {
        Card *firstCard = [self.cards objectAtIndex:firstCardIndex];
        [currentSet removeAllObjects];
        [currentSet addObject:firstCard];
        for (NSUInteger secondCardIndex = firstCardIndex+1; secondCardIndex <= self.numberOfPresentCards-2; secondCardIndex++)
        {
            Card *secondCard = [self.cards objectAtIndex:secondCardIndex];
            if ([currentSet count] == 2)
                [currentSet removeLastObject];
            [currentSet addObject:secondCard];
            for (NSUInteger thirdCardIndex = secondCardIndex+1; thirdCardIndex <= self.numberOfPresentCards-1; thirdCardIndex++)
            {
                Card *thirdCard = [self.cards objectAtIndex:thirdCardIndex];
                //NSLog(@"%d, %d, %d : %@, %@, %@", firstCardIndex, secondCardIndex, thirdCardIndex, firstCard.contents.string, secondCard.contents.string, thirdCard.contents.string);
                int matchScore = [thirdCard match:currentSet];
                if (matchScore) // we have a set
                    return YES;
            }
        }
    }
    return NO;
}

- (void)penalizeUnseenSet
{
    int points = self.numberOfPresentCards - 6;
    self.score -= points;
    NSString *string = [NSString stringWithFormat:@"(%d) You didn't see an existing set.", -points];
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:string];
    [self updateInfo:aString append:NO];
    [self updateHistory];
}

- (void)gameOver
{
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:@"Game over!"];
    [self updateInfo:aString append:NO];
    [self updateHistory];
}
@end