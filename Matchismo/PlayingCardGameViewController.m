//
//  CardGameViewController.m
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
@property (nonatomic, retain, readwrite) NSMutableArray *cardViews;
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

- (void)updateView:(UIView *)view forCard:(Card *)card
{
    if (![card isKindOfClass:[PlayingCard class]]) return;
    if (![view isKindOfClass:[PlayingCardView class]]) return;
    
    PlayingCard *playingCard = (PlayingCard *)card;
    PlayingCardView *playingCardView = (PlayingCardView *)view;
    playingCardView.rank = playingCard.rank;
    playingCardView.suit = playingCard.suit;
    playingCardView.faceUp = playingCard.chosen;
}

- (void)updateMatchedCardView:(UIView *)matchedCardView atIndex:(NSUInteger)index order:(NSUInteger)order total:(NSUInteger)total
{
    CGRect originalFrame = matchedCardView.frame;
    
    /* we won't mess with the matchedCardView directly otherwise we would lose the matched cards
     * look while they go away in the animation (remember, the action inside animation occurs instantly).
     * so we'll create a newCardView. and when the deck is empty, this newCardView will contain the
     * card that was at last position, avoiding holes in the game. */
    PlayingCardView *newCardView;
    PlayingCardView *lastView;
    
    // we need to save the deck condition before dealing new cards because eventually
    // it will become empty right after it...
    BOOL wasDeckEmpty = [self.game isDeckEmpty];
    
    if (!wasDeckEmpty)
    {
        // replace the removed card with a new random one from the deck:
        PlayingCard *card = [self.game dealRandomCardAtIndex:index];
        // associate the new card to the view:
        newCardView = [self createViewForCard:card];
    }
    else if (index < self.game.numberOfPresentCards)
    {
        // deck is empty and the matched card is not the last card
        // it should be numberOfPresentCards-1 but we already removed 1 card...
        lastView = [self.cardViews lastObject];
        [self.cardViews removeObject:lastView];
        // notice that if the last card is a matched card, it was already removed! ;)
        // the animation will take care of showing it going away... and that's it.
        
        // pick up the current last card and change its index:
        PlayingCard *lastCard = [self.game lastCard];
        [self.game removeCard:lastCard];
        [self.game insertCard:lastCard atIndex:index];
        // associate that card to the view:
        newCardView = [self createViewForCard:lastCard];
    }
    if (!(wasDeckEmpty && index == self.game.numberOfPresentCards))
    {
        // won't execute if the deck is empty AND the last card is a matched card.
        // it's the same as joining the two conditions above! this is valid for both.
        newCardView.tag = index;
        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchCardView:)];
        [newCardView addGestureRecognizer:tap];
        newCardView.frame = self.deckFrame; // at first, out of sight
        [self.cardViews insertObject:newCardView atIndex:index];
        [[matchedCardView superview] addSubview:newCardView];
    }
    
    // animation: cards going away
    [UIView animateWithDuration:1
                          delay:0.2*(1+order)
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         matchedCardView.frame = self.deckFrame;
                     } completion:^(BOOL finished){
                         [matchedCardView removeFromSuperview];
                         if (wasDeckEmpty && index == self.game.numberOfPresentCards)
                         {
                             // if there aren't other matched cards to verify, update grid
                             if (order == total-1)
                                 [self updateGrid];
                         }
                         // that's all if the last card is a matched card AND the deck is empty! otherwise...
                         else
                         {
                             // animation: cards coming
                             [UIView animateWithDuration:1
                                                   delay:0.2*(2-order)
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  if (!wasDeckEmpty)
                                                      // card coming from the deck
                                                  { newCardView.frame = originalFrame; }
                                                  else
                                                      // (illusion) last card filling the hole
                                                  { lastView.frame = originalFrame; }
                                              } completion:^(BOOL finished){
                                                  if (wasDeckEmpty)
                                                  {
                                                      // actually the lastView won't be there, it was just
                                                      // illusion. newCardView will be there. once made
                                                      // the illusion, change it instantly!
                                                      [lastView removeFromSuperview];
                                                      newCardView.frame = originalFrame;
                                                      // if there aren't other matched cards to verify, update grid
                                                      if (order == total-1)
                                                          [self updateGrid];
                                                  }
                                              }];
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
