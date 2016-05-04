//
//  Grid.h
//
//  CS193p Fall 2013
//  Copyright (c) 2013 Stanford University.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

// To use Grid, simply alloc/init one, then
//  decide what aspect ratio you want the things in the grid to have (cellAspectRatio)
//  and how much space you want the grid to take up in total (size)
//  then specify what is the minimum number of cells in the grid you require (minimumNumberOfCells)
//
// Setting minimum cell widths and heights is completely optional ({min,max}Cell{Width,Height})

@interface Grid : NSObject

- (instancetype)init __attribute__((unavailable ("One must use the designated initializer: initWithSize:andCellAspectRatio:toContainAtLeast:")));
- (instancetype)initWithSize:(CGSize)size andCellAspectRatio:(CGFloat)aspectRatio toContainAtLeast:(NSUInteger)minimumNumberOfCells NS_DESIGNATED_INITIALIZER;

// required inputs (zero is not a valid value for any of these)

@property (nonatomic) CGSize size;                      // overall available space to put grid into
@property (nonatomic) CGFloat cellAspectRatio;          // width divided by height (of each cell)
@property (nonatomic) NSUInteger minimumNumberOfCells;

// optional inputs (non-positive values are ignored)

@property (nonatomic) CGFloat minCellWidth;
@property (nonatomic) CGFloat maxCellWidth;     // ignored if less than minCellWidth
@property (nonatomic) CGFloat minCellHeight;
@property (nonatomic) CGFloat maxCellHeight;    // ignored if less than minCellHeight

// outputs

- (CGRect)frameOfCellAtRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (CGRect)frameOfCellAtIndex:(NSUInteger)index;

@end
