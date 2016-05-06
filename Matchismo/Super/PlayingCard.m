//
//  PlayingCard.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/1/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

- (int)match:(NSArray *)otherCards
{
    int score = 0;
    for (PlayingCard *card in otherCards)
    {
        if (card.rank == self.rank)
            { score += 4; }
        else if ([card.suit isEqualToString:self.suit])
            { score++; }
    }
    
    return score;
}

- (NSAttributedString *)contents
{
    NSArray *rankStrings = [PlayingCard rankStrings];
    if ([self.suit isEqualToString:@"♥"] || [self.suit isEqualToString:@"♦"])
    {
        return [[NSAttributedString alloc] initWithString:[rankStrings[self.rank] stringByAppendingString:self.suit]
                                               attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
    }
    else
    {
        return [[NSAttributedString alloc] initWithString:[rankStrings[self.rank] stringByAppendingString:self.suit]
                                               attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor]}];
    }
}

+ (NSArray *)validSuits
{
    return @[@"♠",@"♣",@"♥",@"♦"];
}

+ (NSArray *)rankStrings
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",
             @"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+ (NSUInteger)maxRank
{
    return [[self rankStrings] count]-1; // discounting the "?"
}

@synthesize suit = _suit; // as we're rewriting both getter and setter

- (void)setSuit:(NSString *)suit
{
    if ([[PlayingCard validSuits] containsObject:suit])
    {
        _suit = suit;
    }
}

- (NSString *) suit
{
    return _suit ? _suit : @"?"; // returns "?" if suit=0
}

- (void)setRank:(NSUInteger)rank
{
    if (rank <= [PlayingCard maxRank])
    { _rank = rank; }
}
@end
