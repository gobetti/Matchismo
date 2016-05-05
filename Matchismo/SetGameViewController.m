//
//  SetGameViewController.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/9/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCard.h"
#import "SetGame.h"
#import "SetCardView.h"

@interface SetGameViewController ()
@property (strong, nonatomic) SetGame *game;
@property (strong, nonatomic) IBOutlet UIButton *dealButton;
@end

@implementation SetGameViewController

- (SetGame *)game
{
    if (!_game) _game = [[SetGame alloc] initWithCardCount:self.numberOfStartingCards];
    return _game;
}

- (NSUInteger)numberOfStartingCards
{
    return 12;
}

- (UIViewAnimationOptions)animationOptions
{
    return UIViewAnimationOptionCurveEaseInOut;
}

// Reimplemented functions:

- (id)createViewForCard:(id)card
{
    SetCardView *view = [[SetCardView alloc] init];
    [self updateView:view forCard:card];
    return view;
}

- (void)updateView:(CardView *)view forCard:(Card *)card
{
    if (![card isKindOfClass:[SetCard class]]) return;
    if (![view isKindOfClass:[SetCardView class]]) return;
    
    SetCard *setCard = (SetCard *)card;
    SetCardView *setCardView = (SetCardView *)view;
    setCardView.number = setCard.number;
    setCardView.symbol = setCard.symbol;
    setCardView.color = setCard.color;
    setCardView.shading = setCard.shading;
    setCardView.faceUp = YES;
    setCardView.alpha = setCard.chosen ? 0.6 : 1.0;
}

- (BOOL)onAnimationCompletionShouldUpdateGridWhenDeckIsNotEmpty {
    self.dealButton.enabled = YES;
    self.dealButton.alpha = 1.0;
    
    // deal more cards from the deck if the current number is less than the starting one
    if (self.game.numberOfPresentCards < self.numberOfStartingCards) {
        return [self dealMoreCards:3];
    }
    else {
        return NO;
    }
}

- (BOOL)onAnimationCompletionShouldUpdateGridWhenDeckIsEmpty {
    self.dealButton.enabled = NO;
    self.dealButton.alpha = 0.5;
    
    // if there are no more sets, the game is over
    if (!self.game.isThereAnySet)
    {
        [self.game gameOver];
        [self updateUI];
        return NO;
    }
    else {
        return YES;
    }
}

// Specific functions:

- (IBAction)touchDealButton:(UIButton *)sender
{
    if (self.game.isThereAnySet)
    {
        [self.game penalizeUnseenSet];
        [self updateUI];
    }
    if ([self dealMoreCards:3]) {
        [self updateGrid];
    }
}
@end
