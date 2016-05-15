//
//  GameViewController.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/14/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GameViewController : UIViewController

// The methods below should probably not be overridden by subclasses.
// If really necessary, then be sure to call super.
- (void)updateUI;
- (void)updateGrid;
- (IBAction)touchRestartButton:(UIButton *)sender;
- (void)touchCardView:(UITapGestureRecognizer *)gesture;
- (BOOL)dealMoreCards:(NSUInteger)amount;

// The following (private) methods must be overridden by subclasses:
//- (UIViewAnimationOptions) animationOptions;
//- (BOOL)onAnimationCompletionShouldUpdateGridWhenDeckIsNotEmpty;
//- (BOOL)onAnimationCompletionShouldUpdateGridWhenDeckIsEmpty;
//- (id)createViewForCard:(id)card;
//- (void)updateView:(CardView *)view forCard:(id<Card>)card;

@end
