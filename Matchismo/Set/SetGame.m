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
@property (nonatomic, strong) NSMutableSet *chosenCards;
@property (strong, nonatomic) SetDeck *deck; // will hold to this deck
@end

@implementation SetGame

- (SetDeck *)deck
{
    if (!_deck) _deck = [[SetDeck alloc] init];
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

- (NSUInteger)amountOfCardsToChoose {
    return 3;
}

- (NSInteger)pointsWhenMatchedWithLastChosenCard:(Card*)card andScored:(NSInteger)matchScore {
    for (Card *everyCard in self.chosenCards) {
        everyCard.matched = YES;
    }
    
    return 21 - self.numberOfPresentCards;
}

- (NSInteger)pointsWhenNoMatchesWithLastChosenCard:(Card*)card {
    // flip back all the chosen cards:
    for (Card *everyCard in self.chosenCards) {
        everyCard.chosen = NO;
    }
    
    return -self.numberOfPresentCards;
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