//
//  PlayingCardGameViewController.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/1/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCard.h"
#import "PlayingCardGame.h"
#import "PlayingCardView.h"

@interface PlayingCardGameViewController ()
@property (strong, nonatomic) PlayingCardGame *game;
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeSelector;
@end

@implementation PlayingCardGameViewController

- (PlayingCardGame *)game
{
    if (!_game) {
        _game = [[PlayingCardGame alloc] initWithCardCount:self.numberOfStartingCards];
        
        // if 3-card mode is selected on restart,
        if ([self.modeSelector selectedSegmentIndex]) {
            [self.game changeMode];
        }
        
        // ensures that mode changing is enabled when the game (re)starts:
        [self.modeSelector setEnabled:YES forSegmentAtIndex:0];
        [self.modeSelector setEnabled:YES forSegmentAtIndex:1];
    }
    return _game;
}

- (NSUInteger)numberOfStartingCards
{
    return 40;
}

- (UIViewAnimationOptions)animationOptions
{
    return UIViewAnimationOptionTransitionFlipFromRight;
}

// Reimplemented functions:

- (id)createViewForCard:(id)card
{
    PlayingCardView *view = [[PlayingCardView alloc] init];
    [self updateView:view forCard:card];
    return view;
}

- (void)updateView:(CardView *)view forCard:(Card *)card
{
    if (![card isKindOfClass:[PlayingCard class]]) return;
    if (![view isKindOfClass:[PlayingCardView class]]) return;
    
    PlayingCard *playingCard = (PlayingCard *)card;
    PlayingCardView *playingCardView = (PlayingCardView *)view;
    playingCardView.rank = playingCard.rank;
    playingCardView.suit = playingCard.suit;
    playingCardView.faceUp = playingCard.chosen;
}

- (BOOL)onAnimationCompletionShouldUpdateGridWhenDeckIsNotEmpty {
    // deal more cards from the deck (2 or 3, according to the mode)
    return [self dealMoreCards:[self.game mode]];
}

- (BOOL)onAnimationCompletionShouldUpdateGridWhenDeckIsEmpty {
    // no more cards to deal, just update the grid
    return YES;
}

- (void)touchCardView:(UITapGestureRecognizer *)gesture
{
    // currently, there are only two indexes: 0 and 1.
    // when index 1 is selected and a card is chosen, disable index 0, and vice-versa.
    // it will be re-enabled only once the game is restarted.
    [self.modeSelector setEnabled:NO forSegmentAtIndex:![self.modeSelector selectedSegmentIndex]];
    [super touchCardView:gesture];
}

// Specific functions:

- (IBAction)changeCardMode:(UISegmentedControl *)sender
{
    [self.game changeMode];
}
@end
