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
#import "Game.h"

@interface SetGameViewController ()
{
    SetGame *setGame;
}
@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) IBOutlet UIButton *dealButton;
@end

@implementation SetGameViewController

- (void)viewDidLoad
{
    self.delegate = self;
    [super viewDidLoad];
}

- (Game *)game
{
    if (!_game) {
        self->setGame = [[SetGame alloc] init];
        _game = [[Game alloc] initWithDelegate:self->setGame];
        
        self.dealButton.enabled = YES;
        self.dealButton.alpha = 1.0;
    }
    return _game;
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

- (void)updateView:(CardView *)view forCard:(id<Card>)card
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

- (void)onAnimationCompletionWhenDeckIsNotEmpty {
    // deal more cards from the deck if the current number is less than the starting one
    if (self.game.numberOfPresentCards < [self.game numberOfStartingCards]) {
        [self dealMoreCards:[self->setGame amountOfCardsToChoose]];
    }
}

- (void)onAnimationCompletionWhenDeckIsEmpty {
    self.dealButton.enabled = NO;
    self.dealButton.alpha = 0.5;
    
    // if there are no more sets, the game is over
    if ([self->setGame isThereAnySetInGame:self.game]) {
        [self.game gameOver];
    }
}

// Specific functions:

- (IBAction)touchDealButton:(UIButton *)sender
{
    [self dealMoreCards:3];
}

@end
