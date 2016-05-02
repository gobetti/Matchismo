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
#import "CardView.h"

@interface GameViewController ()
@property (strong, nonatomic) Game *game;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (nonatomic, retain, readwrite) NSMutableArray *cardViews;
@property (weak, nonatomic) IBOutlet UIView *gridView;
@property (strong, nonatomic, readwrite) Grid *grid;
@end

@implementation GameViewController

- (void)touchCardView:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        Card *card = [self.game cardAtIndex:gesture.view.tag];
        
        [UIView transitionWithView:gesture.view
                          duration:0.2
                           options:self.animationOptions
                        animations:^{
                            card.chosen = !card.chosen;
                            [self updateView:gesture.view forCard:card];
                        } completion:^(BOOL finished) {
                            card.chosen = !card.chosen;
                            [self.game chooseCardAtIndex:gesture.view.tag];
                            [self updateUI];
                        }];
    }
}

- (void)updateUI
{
    NSMutableArray *matchedIndexes = [[NSMutableArray alloc] init];
    for (NSUInteger cardIndex = 0; cardIndex < self.game.numberOfPresentCards; cardIndex++)
    {
        Card *card = [self.game cardAtIndex:cardIndex];
        CardView *cardView = self.cardViews[cardIndex];
        if (cardView.faceUp != card.chosen)
        {
            [self updateChosenView:cardView forCard:card];
        }
        
        if (card.matched)
        {
            // this function is separated so it could be reimplemented on each game:
            [matchedIndexes addObject:[NSNumber numberWithInteger:cardIndex]];
        }
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    self.infoLabel.attributedText = self.game.info;
    
    if ([matchedIndexes count])
    {
        // re-order the array for removing higher indexes first, so that the next iteration has a valid index:
        [matchedIndexes sortUsingDescriptors:[NSArray arrayWithObject:
                                              [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]];
        
        for (NSNumber *matchedIndex in matchedIndexes)
        {
            NSUInteger index = [matchedIndex integerValue];
            UIView *matchedCardView = [self.cardViews objectAtIndex:index];
            [self.cardViews removeObject:matchedCardView];
            [self.game removeCard:[self.game cardAtIndex:index]];
            [self updateMatchedCardView:matchedCardView atIndex:(NSUInteger)index order:[matchedIndexes indexOfObject:matchedIndex] total:[matchedIndexes count]];
        }
    }
    
}

- (void)updateChosenView:(UIView *)view forCard:(Card *)card
{
    // flips the card or changes transparency (according to the game)
    [UIView transitionWithView:view
                      duration:0.2
                       options:self.animationOptions
                    animations:^{ [self updateView:view forCard:card]; }
                    completion:NULL];
}

- (void)updateGrid
{
    self.grid = nil;
    // recalculate positions
    for (NSUInteger cardIndex = 0; cardIndex < self.game.numberOfPresentCards; cardIndex++)
    {
        UIView *cardView = self.cardViews[cardIndex];
        CGRect frame = [self.grid frameOfCellAtRow:cardIndex / self.grid.columnCount
                                          inColumn:cardIndex % self.grid.columnCount];
        
        // animate only if current position and/or size is different
        if (cardView.frame.size.height != frame.size.height ||
            cardView.frame.origin.x != frame.origin.x ||
            cardView.frame.origin.y != frame.origin.y)
        {
            frame = CGRectInset(frame, 1, 1); // puts some space between cards
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
                         animations:^{
                             cardView.frame = self.deckFrame;
                         } completion:^(BOOL finished){
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
        Card *card = [self.game cardAtIndex:cardIndex];
        UIView *cardView;
        cardView = [self createViewForCard:card];
        cardView.tag = cardIndex;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touchCardView:)];
        [cardView addGestureRecognizer:tap];
        [self.cardViews addObject:cardView];
        [self.gridView addSubview:cardView];
        
        cardView.frame = self.deckFrame;
        CGRect frame = [self.grid frameOfCellAtRow:cardIndex / self.grid.columnCount
                                          inColumn:cardIndex % self.grid.columnCount];
        frame = CGRectInset(frame, 1, 1); // puts some space between cards
        
        [UIView animateWithDuration:0.25
                              delay:0.03*cardIndex
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cardView.frame = frame;
                         } completion:NULL];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self redealCards];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateGrid];
}

- (NSMutableArray *)cardViews
{
    if (!_cardViews) _cardViews = [NSMutableArray arrayWithCapacity:self.numberOfStartingCards];
    return _cardViews;
}

- (Grid *)grid
{
    if (!_grid) {
        _grid = [[Grid alloc] init];
        _grid.cellAspectRatio = 1/1.5;
        if (self.game.numberOfPresentCards)
        {
            _grid.minimumNumberOfCells = self.game.numberOfPresentCards;
        }
        else
        {
            _grid.minimumNumberOfCells = self.numberOfStartingCards;
        }
        _grid.size = self.gridView.frame.size;
    }
    return _grid;
}

- (CGRect)deckFrame
{
    return CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height, self.grid.cellSize.width, self.grid.cellSize.height);
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

- (void)updateMatchedCardView:(UIView *)matchedCardView atIndex:(NSUInteger)index order:(NSUInteger)order total:(NSUInteger)total
{
    // to be implemented on concrete subclasses
    // actions to be taken when there are matched cards
}

- (id)createViewForCard:(id)card
{
    // to be implemented on concrete subclasses
    // associates a card to a view
    return nil;
}

- (void)updateView:(UIView *)view forCard:(Card *)card
{
    // to be implemented on concrete subclasses
    // shows the card face in its respective view
}

/*
 * old methods
 *
 
- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons)
    {
        int cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardButtonIndex];
        [cardButton setAttributedTitle:[self titleForCard:card] forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card] forState:UIControlStateNormal];
        cardButton.enabled = !card.isMatched;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
        self.infoLabel.attributedText = self.game.info;
    }
}

- (IBAction)touchCardButton:(UIButton *)sender
{
    int chosenButtonIndex = [self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:chosenButtonIndex];
    [self updateUI];
}

- (NSAttributedString *)titleForCard:(Card *)card
{
    if (!card.isChosen)
    {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    else
    {
        return [[NSAttributedString alloc] initWithAttributedString:card.contents];
    }
}

- (UIImage *)backgroundImageForCard:(Card *)card
{
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}
 *
 * end of old methods
 */
@end
