//
//  SetDeck.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/5/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "SetDeck.h"
#import "SetCard.h"

@implementation SetDeck

- (instancetype)init
{
    // start the initializer letting the superclass initialize itself first (and check for failure)
    self = [super init];
    
    if (self)
    {
        for (NSString *shading in [SetCard validShadings])
        {
            for (UIColor *color in [SetCard validColors])
            {
                for (NSString *symbol in [SetCard validSymbols])
                {
                    for (NSUInteger number = 1; number <= [SetCard maxNumber]; number++)
                    {
                        SetCard *card = [[SetCard alloc] init];
                        card.number = number;
                        card.symbol = symbol;
                        card.color = color;
                        card.shading = shading;
                        [self addCard:card];
                    }
                }
            }
        }
    }
    
    return self;
}
@end
