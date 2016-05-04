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
                         if (!self.game.isDeckEmpty)
                         {
                             // deal more cards from the deck if the current number is less than the starting one
                             if (self.game.numberOfPresentCards < self.numberOfStartingCards) {
                                 shouldUpdateGrid = [self dealMoreCards];
                             }
                             self.dealButton.enabled = YES;
                             self.dealButton.alpha = 1.0;
                         }
                         else
                         {
                             // the deck is empty, if there are no more sets, the game is over
                             self.dealButton.enabled = NO;
                             self.dealButton.alpha = 0.5;
                             if (!self.game.isThereAnySet)
                             {
                                 [self.game gameOver];
                                 [self updateUI];
                             }
                             else {
                                 shouldUpdateGrid = YES;
                             }
                         }
                         
                         if (shouldUpdateGrid) {
                             [self updateGrid];
                         }
                         
                         // reset tags
                         int tag = 0;
                         for (SetCardView *cardView in self.cardViews)
                         {
                             cardView.tag = tag++;
                         }
                     }];
}

// Specific functions:

- (BOOL)dealMoreCards
{
    NSArray *newCards = [[NSArray alloc] initWithArray:[self.game dealMoreCards]];
    if (!newCards) {
        return NO;
    }

    int newViews = 0;
    for (SetCard *card in newCards)
    {
        SetCardView *cardView;
        cardView = [self createViewForCard:card];
        // the game already has 3 more cards... so the indexes must be cards-3 (+1) (+1)
        cardView.tag = self.game.numberOfPresentCards-3+newViews;
        newViews++;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touchCardView:)];
        [cardView addGestureRecognizer:tap];
        cardView.frame = self.deckFrame;
        [self.cardViews addObject:cardView];
        [[[self.cardViews firstObject] superview] addSubview:cardView];
    }
    if (self.game.isDeckEmpty)
    {
        self.dealButton.enabled = NO;
        self.dealButton.alpha = 0.5;
    }
    
    return YES;
}

- (IBAction)touchDealButton:(UIButton *)sender
{
    if (self.game.isThereAnySet)
    {
        [self.game penalizeUnseenSet];
        [self updateUI];
    }
    if ([self dealMoreCards]) {
        [self updateGrid];
    }
}
@end
