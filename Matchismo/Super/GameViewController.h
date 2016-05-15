//
//  GameViewController.h
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/14/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GameViewController : UIViewController

// Be sure to call the super implementation when overriding
// the methods below:
- (void)touchCardView:(UITapGestureRecognizer *)gesture;
- (void)dealMoreCards:(NSUInteger)amount;

// The following (private) methods must be overridden by subclasses:
//- (UIViewAnimationOptions) animationOptions;
//- (void)onAnimationCompletionWhenDeckIsNotEmpty;
//- (void)onAnimationCompletionWhenDeckIsEmpty;
//- (id)createViewForCard:(id)card;
//- (void)updateView:(CardView *)view forCard:(id<Card>)card;

@end
