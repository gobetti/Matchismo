//
//  SetCard.h
//
//
//  Created by Marcelo Gobetti on 2/5/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "Card.h"

@interface SetCard : Card

@property (nonatomic) NSUInteger number;
@property (strong, nonatomic) NSString *symbol;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *shading;

+ (NSUInteger) maxNumber;
+ (NSArray *)validSymbols;
+ (NSArray *)validColors;
+ (NSArray *)validShadings;

@end