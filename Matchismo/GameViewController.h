//
//  GameViewController.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/14/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GameViewController : UIViewController

@property (nonatomic, retain, readonly) NSMutableArray *cardViews;

@property (nonatomic) NSUInteger numberOfStartingCards;
@property (nonatomic) CGRect deckFrame;
@property (assign) UIViewAnimationOptions animationOptions;

- (void)updateUI;
- (void)updateGrid;
- (IBAction)touchRestartButton:(UIButton *)sender;
- (void)touchCardView:(UITapGestureRecognizer *)gesture;
- (BOOL)dealMoreCards:(NSUInteger)amount;

@end
