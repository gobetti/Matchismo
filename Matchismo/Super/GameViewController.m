//
//  GameViewController.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/14/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "GameViewController.h"
#import "Game.h"
#import "GameHistoryViewController.h"
#import "Grid.h"

@interface GameViewController ()
@property (strong, nonatomic) Game *game;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) NSMutableArray *cardViews;
@property (weak, nonatomic) IBOutlet UIView *gridView;
@property (strong, nonatomic) Grid *grid;
@end

@implementation GameViewController

- (void)touchCardView:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        id<Card> card = [self.game cardAtIndex:gesture.view.tag];
        
        [UIView transitionWithView:gesture.view
                          duration:0.2
                           options:[self.delegate animationOptions]
                        animations:^{
                            card.chosen = !card.chosen;
                            [self.delegate updateView:(CardView*)gesture.view forCard:card];
                        } completion:^(BOOL finished) {
                            card.chosen = !card.chosen;
                            [self.game chooseCardAtIndex:gesture.view.tag];
                        }];
    }
}

- (void)updateUI
{
    NSMutableArray *matchedIndexes = [[NSMutableArray alloc] init];
    for (NSUInteger cardIndex = 0; cardIndex < self.game.numberOfPresentCards; cardIndex++)
    {
        id<Card> card = [self.game cardAtIndex:cardIndex];
        CardView *cardView = self.cardViews[cardIndex];
        if (cardView.faceUp != card.chosen)
        {
            [self updateChosenView:cardView forCard:card];
        }
        
        if (card.matched)
        {
            // the matched cards are put to a separate array in order to be sorted later
            [matchedIndexes addObject:[NSNumber numberWithInteger:cardIndex]];
        }
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", self.game.score];
    self.infoLabel.attributedText = self.game.info;
    
    if ([matchedIndexes count])
    {
        // sort the array in order to remove higher index cards first, so that the next iteration has a valid index:
        [matchedIndexes sortUsingDescriptors:[NSArray arrayWithObject:
                                              [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]];
        NSLog(@"matchedIndexes = %@", matchedIndexes.description);
        for (NSNumber *matchedIndex in matchedIndexes)
        {
            NSUInteger index = [matchedIndex integerValue];
            CardView *matchedCardView = [self.cardViews objectAtIndex:index];
            [self.cardViews removeObject:matchedCardView];
            [self.game removeCard:[self.game cardAtIndex:index]];
            [self updateMatchedCardView:matchedCardView atIndex:index animationOrder:[matchedIndexes indexOfObject:matchedIndex] totalOfMatchedCards:[matchedIndexes count]];
        }
    }
    
}

- (void)updateChosenView:(CardView *)view forCard:(id<Card>)card
{
    // flips the card or changes transparency (according to the game)
    [UIView transitionWithView:view
                      duration:0.2
                       options:[self.delegate animationOptions]
                    animations:^{ [self.delegate updateView:view forCard:card]; }
                    completion:NULL];
}

- (void)updateGrid
{
    NSLog(@"updating grid");
    self.grid = nil;
    // recalculate positions
    for (NSUInteger cardIndex = 0; cardIndex < self.game.numberOfPresentCards; cardIndex++)
    {
        UIView *cardView = self.cardViews[cardIndex];
        CGRect frame = [self cardFrameAtIndex:cardIndex];
        
        // animate only if current position and/or size is different
        if (cardView.frame.size.height != frame.size.height ||
            cardView.frame.origin.x != frame.origin.x ||
            cardView.frame.origin.y != frame.origin.y)
        {
            [UIView animateWithDuration:0.5
                                  delay:0.05*cardIndex
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{ cardView.frame = frame; }
                             completion:NULL];
            
        }
    }
}

- (IBAction)touchRestartButton:(UIButton *)sender
{
    for (UIView *cardView in self.cardViews)
    {
        [UIView animateWithDuration:0.25
                              delay:0.03*[self.cardViews indexOfObject:cardView]
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{ cardView.frame = self.deckFrame; }
                         completion:^(BOOL finished){
                             [cardView removeFromSuperview];
                             // reset game and redeal cards after last animation finishes
                             if ([self.cardViews indexOfObject:cardView] == [self.cardViews count]-1)
                             {
                                 [self setNewGame];
                                 [self redealCards];
                             }
                         }];
        
    }
}

- (void)setNewGame
{
    self.cardViews = nil;
    self.game = nil;
    self.grid = nil;
    self.infoLabel.text = @"Touch a card to begin!";
    self.scoreLabel.text = @"Score: 0";
}

- (void)redealCards
{
    for (NSUInteger cardIndex = 0; cardIndex < self.game.numberOfPresentCards; cardIndex++)
    {
        id<Card> card = [self.game cardAtIndex:cardIndex];
        UIView *cardView;
        cardView = [self.delegate createViewForCard:card];
        cardView.tag = cardIndex;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touchCardView:)];
        [cardView addGestureRecognizer:tap];
        [self.cardViews addObject:cardView];
        [self.gridView addSubview:cardView];
        
        [UIView animateWithDuration:0.25
                              delay:0.03*cardIndex
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{ cardView.frame = [self cardFrameAtIndex:cardIndex]; }
                         completion:NULL];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self redealCards];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:@"updateUI"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUI" object:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateGrid];
}

- (NSMutableArray *)cardViews
{
    if (!_cardViews) _cardViews = [NSMutableArray arrayWithCapacity:[self.game numberOfStartingCards]];
    return _cardViews;
}

- (Grid *)grid
{
    if (!_grid) {
        NSUInteger minimumNumberOfCells = 0;
        if (self.game.numberOfPresentCards)
        {
            minimumNumberOfCells = [self.game numberOfPresentCards];
        }
        else
        {
            minimumNumberOfCells = [self.game numberOfStartingCards];
        }
        
        _grid = [[Grid alloc] initWithSize:self.gridView.frame.size andCellAspectRatio:1/1.5 toContainAtLeast:minimumNumberOfCells];
    }
    return _grid;
}

- (CGRect)deckFrame
{
    // the deck frame has the same size as any card, but it stays out of the screen
    CGRect cardFrame = [self.grid frameOfCellAtIndex:0];
    return CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height,
                      cardFrame.size.width, cardFrame.size.height);
}

- (CGRect)cardFrameAtIndex:(NSUInteger)index
{
    return CGRectInset([self.grid frameOfCellAtIndex:index], 1, 1); // puts some space between cards
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // pass here the data the new ViewController needs
    if ([[segue identifier] isEqualToString:@"segueToGameHistory"])
    {
        GameHistoryViewController *historyViewController = [segue destinationViewController];
        historyViewController.history = self.game.history;
    }
}

- (void)dealMoreCards:(NSUInteger)amount
{
    NSArray *newCards = [[NSArray alloc] initWithArray:[self.game dealMoreCards:amount]];
    // resetting "amount" to the real amount of cards got from the game:
    amount = [newCards count];
    if (amount == 0) {
        return;
    }
    
    int newViews = 0;
    for (id<Card> card in newCards)
    {
        CardView *cardView;
        cardView = [self.delegate createViewForCard:card];
        cardView.tag = self.game.numberOfPresentCards - amount + newViews;
        newViews++;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touchCardView:)];
        [cardView addGestureRecognizer:tap];
        cardView.frame = self.deckFrame;
        [self.cardViews addObject:cardView];
        [[[self.cardViews firstObject] superview] addSubview:cardView];
    }
    
    [self updateGrid];
}

- (void)updateMatchedCardView:(CardView *)cardView atIndex:(NSUInteger)index animationOrder:(NSUInteger)order totalOfMatchedCards:(NSUInteger)total
{    // animation: cards going away
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
                         if (!self.game.isDeckEmpty) {
                             [self.delegate onAnimationCompletionWhenDeckIsNotEmpty];
                         }
                         // not using "else", because the deck could have been emptied after dealing more cards:
                         if (self.game.isDeckEmpty) {
                             [self.delegate onAnimationCompletionWhenDeckIsEmpty];
                             [self updateGrid];
                         }
                         
                         // reset tags
                         int tag = 0;
                         for (CardView* cardView in self.cardViews)
                         {
                             cardView.tag = tag++;
                         }
                     }];
}

@end
