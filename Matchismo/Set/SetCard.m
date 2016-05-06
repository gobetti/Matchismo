//
//  SetCard.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/5/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "SetCard.h"

@implementation SetCard

- (int)match:(NSArray *)otherCards
{
    SetCard *firstCard = [otherCards firstObject];
    SetCard *secondCard = [otherCards lastObject];
    int score = 0;
    
    if (firstCard && secondCard)
    {
        if ((self.number == firstCard.number && self.number == secondCard.number) ||
            (self.number != firstCard.number && firstCard.number != secondCard.number && self.number != secondCard.number))
        {
            if (([self.symbol isEqualToString:firstCard.symbol] && [self.symbol isEqualToString:secondCard.symbol]) ||
                (![self.symbol isEqualToString:firstCard.symbol] && ![firstCard.symbol isEqualToString:secondCard.symbol] && ![self.symbol isEqualToString:secondCard.symbol]))
            {
                if (([self.color isEqual:firstCard.color] && [self.color isEqual:secondCard.color]) ||
                    (![self.color isEqual:firstCard.color] && ![firstCard.color isEqual:secondCard.color] && ![self.color isEqual:secondCard.color]))
                {
                    if (([self.shading isEqualToString:firstCard.shading] && [self.shading isEqualToString:secondCard.shading]) ||
                        (![self.shading isEqualToString:firstCard.shading] && ![firstCard.shading isEqualToString:secondCard.shading] && ![self.shading isEqualToString:secondCard.shading]))
                    {
                        score = 4;
                    }
                }
            }
        }
    }
    
    
    return score;
}

- (NSAttributedString *)contents
{
    NSMutableDictionary *cardAttributes;
    if ([self.shading isEqualToString:@"solid"])
    {
        cardAttributes = [[NSMutableDictionary alloc] initWithObjects:@[self.color]
                                                              forKeys:@[NSForegroundColorAttributeName]];
    }
    else if ([self.shading isEqualToString:@"striped"])
    {
        cardAttributes = [[NSMutableDictionary alloc]
                          initWithObjects:@[[self.color colorWithAlphaComponent:0.4], self.color, @-5]
                          forKeys:@[NSForegroundColorAttributeName, NSStrokeColorAttributeName, NSStrokeWidthAttributeName]];
    }
    else if ([self.shading isEqualToString:@"open"])
    {
        cardAttributes = [[NSMutableDictionary alloc]
                          initWithObjects:@[[self.color colorWithAlphaComponent:0], self.color, @-5]
                          forKeys:@[NSForegroundColorAttributeName, NSStrokeColorAttributeName, NSStrokeWidthAttributeName]];
    }
    
    NSString *symbol = [[NSString alloc] init];
    NSMutableString *cardSymbols = [[NSMutableString alloc] init];
    NSArray *validSymbols = [SetCard validSymbols];
    
    if ([self.symbol isEqualToString:validSymbols[0]])
    {
        symbol = @"◼︎";
    }
    else if ([self.symbol isEqualToString:validSymbols[1]])
    {
        symbol = @"▲";
    }
    else if ([self.symbol isEqualToString:validSymbols[2]])
    {
        symbol = @"●";
        // make circles a little bigger:
        [cardAttributes setObject:[UIFont fontWithName:@"Palatino-Roman" size:18]
                           forKey:NSFontAttributeName];
    }
    else
    {
        symbol = @"?";
    }
    
    for (NSUInteger number = 1; number <= self.number; number++)
    {
        [cardSymbols appendString:symbol];
    }
    
    return [[NSAttributedString alloc] initWithString:cardSymbols attributes:cardAttributes];
}

- (void)setSymbol:(NSString *)symbol // security custom setter
{
    if ([[SetCard validSymbols] containsObject:symbol])
    {
        _symbol = symbol;
    }
}

- (void)setShading:(NSString *)shading // security custom setter
{
    if ([[SetCard validShadings] containsObject:shading])
    {
        _shading = shading;
    }
}

- (void)setNumber:(NSUInteger)number // security custom setter
{
    if (number <= [SetCard maxNumber])
    {
        _number = number;
    }
}

- (void)setColor:(UIColor *)color // security custom setter
{
    if ([[SetCard validColors] containsObject:color])
    {
        _color = color;
    }
}

+ (NSUInteger) maxNumber
{
    return 3;
}

+ (NSArray *)validSymbols
{
    return @[@"diamond",@"squiggle",@"oval"];
}

+ (NSArray *)validColors
{
    return @[[UIColor redColor],[UIColor greenColor],[UIColor purpleColor]];
}

+ (NSArray *)validShadings
{
    return @[@"solid",@"striped",@"open"];
}

@end
