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
@property (nonatomic, retain, readwrite) NSMutableArray *cardViews;
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

- (void)updateView:(UIView *)view forCard:(Card *)card
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

- (void)updateMatchedCardView:(UIView *)matchedCardView atIndex:(NSUInteger)index order:(NSUInteger)order total:(NSUInteger)total
{
    // animation: cards going away
    [UIView animateWithDuration:1
                          delay:0.2*(1+order)
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         matchedCardView.frame = self.deckFrame;
                     } completion:^(BOOL finished){
                         [matchedCardView removeFromSuperview];
                         // if there aren't other matched cards to verify, update grid and enable Deal button
                         if (order == total-1)
                         {
                             if (!self.game.isDeckEmpty)
                             {
                                 if (self.game.numberOfPresentCards < 12)
                                     [self touchDealButton:nil];
                                 self.dealButton.enabled = YES;
                                 self.dealButton.alpha = 1.0;
                             }
                             else
                             {
                                 self.dealButton.enabled = NO;
                                 self.dealButton.alpha = 0.5;
                                 if (!self.game.isThereAnySet)
                                 {
                                     [self.game gameOver];
                                     [self updateUI];
                                 }
                             }
                             int tag = 0;
                             for (SetCardView *cardView in self.cardViews)
                             {
                                 // reset tags
                                 cardView.tag = tag++;
                             }
                             [self updateGrid];
                         }
                     }];
    
}

// Specific functions:
- (IBAction)touchDealButton:(UIButton *)sender
{
    if (sender && self.game.isThereAnySet)
    {
        // when a set is found, we deal 3 more cards automatically
        // then this method will be called without a sender...
        // and thus the player won't be penalized ;)
        [self.game penalizeUnseenSet];
        [self updateUI];
    }
    NSArray *newCards = [[NSArray alloc] initWithArray:[self.game dealMoreCards]];
    if (newCards)
    {
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
        [self updateGrid];
    }
}
@end
