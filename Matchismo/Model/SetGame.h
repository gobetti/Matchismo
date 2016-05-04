//
//  SetGame.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/9/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Game.h"
#import "SetCard.h"

@interface SetGame : Game

- (BOOL)isThereAnySet;
- (void)penalizeUnseenSet;
- (void)gameOver;

@end
