//
//  SetCard.h
//
//
//  Created by Marcelo Gobetti on 2/5/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Card.h"

@interface SetCard : NSObject <Card>

@property (nonatomic) NSUInteger number;
@property (strong, nonatomic) NSString *symbol;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *shading;

+ (NSUInteger) maxNumber;
+ (NSArray *)validSymbols;
+ (NSArray *)validColors;
+ (NSArray *)validShadings;

#pragma mark - Card protocol:

@property (strong, nonatomic) NSAttributedString *contents;

@property (nonatomic, getter=isChosen) BOOL chosen;
@property (nonatomic, getter=isMatched) BOOL matched;

- (int)match:(NSArray *) otherCards;

@end