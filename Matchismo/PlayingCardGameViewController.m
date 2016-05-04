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
    if (!_game) _game = [[PlayingCardGame alloc] initWithCardCount:self.numberOfStartingCards];
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

- (void)updateMatchedCardView:(CardView *)cardView atIndex:(NSUInteger)index animationOrder:(NSUInteger)order totalOfMatchedCards:(NSUInteger)total
{
    // animation: cards going away
    [UIView animateWithDuration:1
                          delay:0.2*(1+order)
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ cardView.frame = self.deckFrame; }
                     completion:^(BOOL finished){
                         [cardView removeFromSuperview];
                         if (order < total-1) {
                             return;
                         }
                         
                         // if this is the last matched card:
                         BOOL shouldUpdateGrid = NO;
                         if (!self.game.isDeckEmpty) {
                             // deal more cards from the deck (2 or 3, according to the mode)
                             shouldUpdateGrid = [self dealMoreCards:[self.game mode]];
                         }
                         else {
                             // no more cards to deal, just update the grid
                             shouldUpdateGrid = YES;
                         }
                         
                         if (shouldUpdateGrid) {
                             [self updateGrid];
                         }
                         
                         // reset tags
                         int tag = 0;
                         for (PlayingCardView *cardView in self.cardViews)
                         {
                             cardView.tag = tag++;
                         }
                     }];
}

- (IBAction)touchRestartButton:(UIButton *)sender
{
    // if 3-card mode is selected on restart,
    if ([self.modeSelector selectedSegmentIndex])
        [self.game changeMode];
    // re-enable mode changing:
    [self.modeSelector setEnabled:YES forSegmentAtIndex:![self.modeSelector selectedSegmentIndex]];
    
    [super touchRestartButton:nil];
}

- (void)touchCardView:(UITapGestureRecognizer *)gesture
{
    [self.modeSelector setEnabled:NO forSegmentAtIndex:![self.modeSelector selectedSegmentIndex]];
    [super touchCardView:gesture];
}

// Specific functions:

- (IBAction)changeCardMode:(UISegmentedControl *)sender
{
    [self.game changeMode];
}
@end
