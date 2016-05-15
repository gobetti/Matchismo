//
//  SetGame.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/9/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "SetGame.h"
#import "SetDeck.h"

@implementation SetGame

- (Deck *)deck
{
    return [[SetDeck alloc] init];
}

- (unsigned int)numberOfStartingCards {
    return 12;
}

- (unsigned int)cardChoosingCost {
    return 1;
}

- (unsigned int)amountOfCardsToChoose {
    return 3;
}

- (int)pointsWhenMatchedWithLastChosenCard:(id<Card>)card andScored:(int)matchScore inGame:(Game *)game
{
    for (id<Card> everyCard in game.chosenCards) {
        everyCard.matched = YES;
    }
    
    return 21 - (int)[game numberOfPresentCards];
}

- (int)pointsWhenNoMatchesWithLastChosenCard:(id<Card>)card inGame:(Game *)game
{
    // flip back all the chosen cards:
    for (id<Card> everyCard in game.chosenCards) {
        everyCard.chosen = NO;
    }
    
    return -(int)[game numberOfPresentCards];
}

- (void)willDealMoreCardsInGame:(Game *)game
{
    if ([game numberOfPresentCards] < [self numberOfStartingCards]) {
        // no penalty in this case, it has only got here because the user just found a set
        return;
    }
    
    if (![self isThereAnySetInGame:game]) {
        // the user was right to request more cards: no set is available in the table
        return;
    }
    
    // the user requested to deal more cards, but there was at least 1 set
    // among the cards in the table. Penalize the score:
    int points = (int)[game numberOfPresentCards] - 6;
    game.score -= points;
    NSString *string = [NSString stringWithFormat:@"(%d) You didn't see an existing set.", -points];
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:string];
    [game updateInfo:aString append:NO];
    [game updateHistory];
    
    // inform the UI to update
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUI" object:nil];
}

- (BOOL)isThereAnySetInGame:(Game *)game
{
    NSMutableArray *currentSet = [[NSMutableArray alloc] init];
    // won't use for (... in ...) to avoid repetitions of combinations
    for (NSUInteger firstCardIndex = 0; firstCardIndex <= [game.cards count] - 3; firstCardIndex++)
    {
        id<Card> firstCard = [game.cards objectAtIndex:firstCardIndex];
        [currentSet removeAllObjects];
        [currentSet addObject:firstCard];
        for (NSUInteger secondCardIndex = firstCardIndex+1; secondCardIndex <= [game.cards count] - 2; secondCardIndex++)
        {
            id<Card> secondCard = [game.cards objectAtIndex:secondCardIndex];
            if ([currentSet count] == 2)
                [currentSet removeLastObject];
            [currentSet addObject:secondCard];
            for (NSUInteger thirdCardIndex = secondCardIndex+1; thirdCardIndex <= [game.cards count] - 1; thirdCardIndex++)
            {
                id<Card> thirdCard = [game.cards objectAtIndex:thirdCardIndex];
                //NSLog(@"%d, %d, %d : %@, %@, %@", firstCardIndex, secondCardIndex, thirdCardIndex, firstCard.contents.string, secondCard.contents.string, thirdCard.contents.string);
                int matchScore = [thirdCard match:currentSet];
                if (matchScore) // we have a set
                    return YES;
            }
        }
    }
    return NO;
}

@end