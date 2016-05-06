//
//  PlayingCardView.h
//  SuperCard
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "CardView.h"

@interface PlayingCardView : CardView

@property (nonatomic) NSUInteger rank;
@property (strong, nonatomic) NSString *suit;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;

@end
