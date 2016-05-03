//
//  Grid.m
//
//  CS193p Fall 2013
//  Copyright (c) 2013 Stanford University.
//  All rights reserved.
//

#import "Grid.h"

@interface Grid()
@property (nonatomic) BOOL resolved;
@property (nonatomic, readwrite) NSUInteger rowCount;
@property (nonatomic, readwrite) NSUInteger columnCount;
@property (nonatomic, readwrite) CGSize cellSize;
@property (nonatomic) double dxToCenter;
@end

@implementation Grid

- (void)validate
{
    if (self.resolved) return;    // already valid, nothing to do

    double overallWidth = ABS(self.size.width);
    double overallHeight = ABS(self.size.height);
    double aspectRatio = ABS(self.cellAspectRatio);

    double minCellWidth = self.minCellWidth;
    double minCellHeight = self.minCellHeight;
    double maxCellWidth = self.maxCellWidth;
    double maxCellHeight = self.maxCellHeight;
    
    BOOL flipped = NO;
    if (aspectRatio > 1) {
        flipped = YES;
        overallHeight = ABS(self.size.width);
        overallWidth = ABS(self.size.height);
        aspectRatio = 1.0/aspectRatio;
        minCellWidth = self.minCellHeight;
        minCellHeight = self.minCellWidth;
        maxCellWidth = self.maxCellHeight;
        maxCellHeight = self.maxCellWidth;
    }
    
    if (minCellWidth < 0) minCellWidth = 0;
    if (minCellHeight < 0) minCellHeight = 0;
    
    // get maximal area a card could ever have:
    double cellArea = overallWidth * overallHeight / self.minimumNumberOfCells;
    // as width and height are fixely related by aspect ratio, get maximal width:
    double cellWidth = sqrt(cellArea * aspectRatio);
    // get the minimal number of lines at this card width:
    int columnCount = floor(overallWidth / cellWidth);
    if (columnCount == 0) columnCount = 1;
    // adjust the card width to the integer number of columns:
    cellWidth = overallWidth / columnCount;
    double cellHeight = cellWidth / aspectRatio;
    // get the minimal number of lines at this card height:
    int rowCount = floor(overallHeight / cellHeight);
    if (rowCount == 0)
    {
        rowCount = 1;
        cellHeight = overallHeight;
        cellWidth = cellHeight * aspectRatio;
    }
    // we have some nice initial estimations.
    // now let's check if we need more rows/columns and how many.
    while (!self.resolved)
    {
        if (self.minimumNumberOfCells <= columnCount * rowCount)
        {
            if (overallWidth >= columnCount * cellWidth)
            {
                if (overallHeight >= rowCount * cellHeight)
                {
                    // conditions are all fine, we just need to set it at maximal specified dimensions if higher...
                    if (maxCellWidth && maxCellHeight)
                    {
                        if (cellWidth > maxCellWidth || cellHeight > maxCellHeight)
                        {
                            cellWidth = maxCellWidth;
                            cellHeight = maxCellHeight;
                        }
                    }
                    
                    if (flipped)
                    {
                        self.rowCount = columnCount;
                        self.columnCount = rowCount;
                        self.cellSize = CGSizeMake(cellHeight, cellWidth);
                    }
                    else
                    {
                        self.rowCount = rowCount;
                        self.columnCount = columnCount;
                        self.cellSize = CGSizeMake(cellWidth, cellHeight);
                    }
                    self.dxToCenter = (overallWidth - cellWidth*columnCount)/2;
                    self.resolved = YES;
                }
                else
                {
                    // reduce height to fit
                    cellHeight = overallHeight / rowCount;
                    cellWidth = cellHeight * aspectRatio;
                }
            }
            else
            {
                // reduce width to fit
                cellWidth = overallWidth / columnCount;
                cellHeight = cellWidth / aspectRatio;
            }
        }
        else
        {
            // increase rows and/or columns...
            if ((self.minimumNumberOfCells <= (rowCount+1) * columnCount) &&
                (self.minimumNumberOfCells <= rowCount * (columnCount + 1)))
            {
                // both increases will work, choose the lowest product.
                if ((rowCount+1) * columnCount < rowCount * (columnCount + 1))
                {
                    rowCount++;
                }
                else
                {
                    columnCount++;
                }
            }
            else if (self.minimumNumberOfCells <= (rowCount+1) * columnCount)
            {
                // more rows
                rowCount++;
            }
            else if (self.minimumNumberOfCells <= rowCount * (columnCount + 1))
            {
                // more columns
                columnCount++;
            }
            else
            {
                // more rows and more columns
                rowCount++;
                columnCount++;
            }
        }
    }
}

- (BOOL)inputsAreValid
{
    [self validate];
    return self.resolved;
}

- (CGRect)frameOfCellAtRow:(NSUInteger)row inColumn:(NSUInteger)column
{
    CGRect frame = CGRectMake(0, 0, self.cellSize.width, self.cellSize.height);
    frame.origin.x += column * self.cellSize.width + self.dxToCenter;
    frame.origin.y += row * self.cellSize.height;
    return frame;
}

- (instancetype)initWithSize:(CGSize)size andCellAspectRatio:(CGFloat)aspectRatio toContainAtLeast:(NSUInteger)minimumNumberOfCells
{
    if (!(self = [super init]))
        return nil;
    
    self->_size = size;
    self->_cellAspectRatio = aspectRatio;
    self->_minimumNumberOfCells = minimumNumberOfCells;
    
    return self;
}

- (void)setMinimumNumberOfCells:(NSUInteger)minimumNumberOfCells
{
    if (minimumNumberOfCells != _minimumNumberOfCells) self.resolved = NO;
    _minimumNumberOfCells = minimumNumberOfCells;
}

- (void)setSize:(CGSize)size
{
    if (!CGSizeEqualToSize(size, _size)) self.resolved = NO;
    _size = size;
}

- (void)setCellAspectRatio:(CGFloat)cellAspectRatio
{
    if (ABS(cellAspectRatio) != ABS(_cellAspectRatio)) self.resolved = NO;
    _cellAspectRatio = cellAspectRatio;
}

- (void)setMinCellHeight:(CGFloat)minCellHeight
{
    if (minCellHeight != _minCellHeight) self.resolved = NO;
    _minCellHeight = minCellHeight;
}

- (void)setMaxCellHeight:(CGFloat)maxCellHeight
{
    if (maxCellHeight != _maxCellHeight) self.resolved = NO;
    _maxCellHeight = maxCellHeight;
}

- (void)setMinCellWidth:(CGFloat)minCellWidth
{
    if (minCellWidth != _minCellHeight) self.resolved = NO;
    _minCellWidth = minCellWidth;
}

- (void)setMaxCellWidth:(CGFloat)maxCellWidth
{
    if (maxCellWidth != _maxCellWidth) self.resolved = NO;
    _maxCellWidth = maxCellWidth;
}

- (NSUInteger)rowCount
{
    [self validate];
    return _rowCount;
}

- (NSUInteger)columnCount
{
    [self validate];
    return _columnCount;
}

- (CGSize)cellSize
{
    [self validate];
    return _cellSize;
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"[%@] fitting %lu cells with aspect ratio %g into %@ -> ", NSStringFromClass([self class]), (unsigned long)self.minimumNumberOfCells, self.cellAspectRatio, NSStringFromCGSize(self.size)];
    
    if (!self.rowCount) {
        description = [description stringByAppendingString:@"invalid input: "];
        if (!self.minimumNumberOfCells || !self.cellAspectRatio || !self.size.width || !self.size.height) {
            if (!self.minimumNumberOfCells) description = [description stringByAppendingString:@"minimumNumberOfCells = 0;"];
            if (!self.cellAspectRatio) description = [description stringByAppendingString:@"cellAspectRatio = 0;"];
            if (!self.size.width) description = [description stringByAppendingString:@"size.width = 0;"];
            if (!self.size.height) description = [description stringByAppendingString:@"size.height = 0;"];
        } else {
            
            if (self.minCellWidth || self.minCellHeight) {
                description = [description stringByAppendingString:@"minimum width or height restricts grid to impossibility"];
                if (self.minCellWidth && self.minCellHeight) {
                    description = [description stringByAppendingFormat:@" (minCellWidth = %g, minCellHeight = %g)", self.minCellWidth, self.minCellHeight];
                } else if (self.minCellWidth) {
                    description = [description stringByAppendingFormat:@" (minCellWidth = %g)", self.minCellWidth];
                } else {
                    description = [description stringByAppendingFormat:@" (minCellHeight = %g)", self.minCellHeight];
                }
            } else {
                description = [description stringByAppendingString:@"internal error"];
            }
        }
    } else {
        description = [description stringByAppendingFormat:@"%luc x %lur at %@ each", (unsigned long)self.columnCount, (unsigned long)self.rowCount, NSStringFromCGSize(self.cellSize)];
    }
    
    return description;
}

@end
