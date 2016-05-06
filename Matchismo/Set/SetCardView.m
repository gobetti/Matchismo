//
//  PlayingCardView.m
//  SuperCard
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "SetCardView.h"
#import "SetCard.h"

@interface SetCardView()

@end

@implementation SetCardView

#pragma mark - Properties

- (void)setNumber:(NSUInteger)number
{
    _number = number;
    [self setNeedsDisplay];
}

- (void)setSymbol:(NSString *)symbol
{
    _symbol = symbol;
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void)setShading:(NSString *)shading
{
    _shading = shading;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.faceUp) {
        [self drawCard];
    } else {
        [[UIImage imageNamed:@"cardback"] drawInRect:self.bounds];
    }
}

#define SYMBOL_FONT_SCALE_FACTOR 0.02
#define SYMBOL_HOFFSET_PERCENTAGE SYMBOL_FONT_SCALE_FACTOR*5

- (void)drawCard
{
    if (self.number == 1 || self.number == 3)
        [self drawSymbolWithHorizontalOffset:0];
    
    if (self.number == 2 || self.number == 3)
    {
        [self drawSymbolWithHorizontalOffset:self.number*SYMBOL_HOFFSET_PERCENTAGE];
    }
}

- (void)drawSymbolWithHorizontalOffset:(CGFloat)hoffset
{
    CGPoint middle = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    NSAttributedString *attributedSymbol = [[NSAttributedString alloc] initWithString:[self symbolAsString] attributes:[self cardAttributes]];
    CGSize symbolSize = [attributedSymbol size];
    CGPoint symbolOrigin = CGPointMake(middle.x-symbolSize.width/2.0-hoffset*self.bounds.size.width,
                                       middle.y-symbolSize.height/2.0);
    [attributedSymbol drawAtPoint:symbolOrigin];
    if (hoffset) {
        symbolOrigin.x += hoffset*2.0*self.bounds.size.width;
        [attributedSymbol drawAtPoint:symbolOrigin];
    }
}

- (NSString *)symbolAsString
{
    NSArray *validSymbols = [SetCard validSymbols];
    if ([self.symbol isEqualToString:validSymbols[0]])
    {
        return @"◼︎";
    }
    else if ([self.symbol isEqualToString:validSymbols[1]])
    {
        return @"▲";
    }
    else if ([self.symbol isEqualToString:validSymbols[2]])
    {
        return @"●";
    }
    else
    {
        return @"?";
    }
}

- (NSDictionary *)cardAttributes
{
    NSMutableDictionary *cardAttributes;
    if ([self.shading isEqualToString:@"solid"])
    {
        cardAttributes = [[NSMutableDictionary alloc] initWithObjects:@[self.color]
                                                              forKeys:@[NSForegroundColorAttributeName]];
    }
    else if ([self.shading isEqualToString:@"striped"])
    {
        cardAttributes = [[NSMutableDictionary alloc]
                          initWithObjects:@[[self.color colorWithAlphaComponent:0.4], self.color, @-5]
                          forKeys:@[NSForegroundColorAttributeName, NSStrokeColorAttributeName, NSStrokeWidthAttributeName]];
    }
    else if ([self.shading isEqualToString:@"open"])
    {
        cardAttributes = [[NSMutableDictionary alloc]
                          initWithObjects:@[[self.color colorWithAlphaComponent:0], self.color, @-5]
                          forKeys:@[NSForegroundColorAttributeName, NSStrokeColorAttributeName, NSStrokeWidthAttributeName]];
    }
    
    UIFont *symbolFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    symbolFont = [symbolFont fontWithSize:[symbolFont pointSize] * self.bounds.size.width * SYMBOL_FONT_SCALE_FACTOR];
    
    [cardAttributes setObject:symbolFont forKey:NSFontAttributeName];
    
    return cardAttributes;
}

@end
