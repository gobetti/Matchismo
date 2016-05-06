//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/1/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Game.h"
#import "PlayingCard.h"

@interface PlayingCardGame : Game

@property (nonatomic, readonly) NSUInteger mode;

- (void)changeMode;

@end