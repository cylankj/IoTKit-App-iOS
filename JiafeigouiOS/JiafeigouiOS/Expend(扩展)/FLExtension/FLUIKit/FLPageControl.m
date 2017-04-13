//
//  FLPageControl.m
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "FLPageControl.h"

static CGFloat const DefaultPageIndicatorSize = 7;
static CGFloat const DefaultPageIndicatorSpacing = 9;

@implementation FLPageControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setPageIndicatorSpacing:DefaultPageIndicatorSpacing];
    [self updatePageControl];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage < 0 || currentPage >= self.numberOfPages) {
        return;
    }
    [super setCurrentPage:currentPage];
    [self updatePageControl];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (numberOfPages != self.numberOfPages) {
        [super setNumberOfPages:MAX(0, numberOfPages)];
        [self updatePageControl];
    }
}

- (void)setTotalAndCurrentPageNumber:(NSInteger)totalPageNumber currentPageNumber:(NSInteger)currentPageNumber {
    [self setNumberOfPages:totalPageNumber];
    [self setCurrentPage:currentPageNumber];
}

- (void)setImagePageStateNormal:(UIImage *)imageNormal {
    _imagePageStateNormal = imageNormal;
    [self updatePageControl];
}

- (void)setImagePageStateHighlighted:(UIImage *)imageHighlighted {
    _imagePageStateHighlighted = imageHighlighted;
    [self updatePageControl];
}

- (void)setImageOfPageNormalAndHighlighted:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage {
    [self setImagePageStateNormal:normalImage];
    [self setImagePageStateHighlighted:highlightedImage];
}

- (void)setColorOfBackgroundAndCurrentPageIndicator:(UIColor *)colorOfBackground colorOfCurrentPageIndicator:(UIColor *)colorOfCurrentPageIndicator {
    [self setBackgroundColor:colorOfBackground];
    [self setCurrentPageIndicatorTintColor:colorOfCurrentPageIndicator];
}

- (void)setPageIndicatorSpacing:(NSInteger)indicatorSpacing {
    if (indicatorSpacing != _pageIndicatorSpacing) {
        _pageIndicatorSpacing = indicatorSpacing;
        [self updatePageControl];
    }
}

- (void)updatePageControl {
    if (_imagePageStateNormal && [self respondsToSelector:@selector(setPageIndicatorTintColor:)]) {
        self.pageIndicatorTintColor = [UIColor clearColor];
    }
    if (_imagePageStateHighlighted && [self respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)]) {
        self.currentPageIndicatorTintColor = [UIColor clearColor];
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)iRect {
    CGRect rect;
    UIImage *image;
    iRect = self.bounds;
    
    if ( self.opaque ) {
        [self.backgroundColor set];
        UIRectFill( iRect );
    }
    
    float bigWidth = MAX(_imagePageStateHighlighted.size.width, _imagePageStateNormal.size.width);
    float bigHeight = MAX(_imagePageStateHighlighted.size.height,_imagePageStateNormal.size.height);
    bigWidth = MAX(bigWidth, DefaultPageIndicatorSize);
    bigHeight = MAX(bigHeight, DefaultPageIndicatorSize);
    
    rect.size.height = bigHeight;
    rect.size.width = self.numberOfPages * bigWidth + ( self.numberOfPages - 1 ) * _pageIndicatorSpacing;
    rect.origin.x = floorf( ( iRect.size.width - rect.size.width ) / 2.0 );
    rect.origin.y = floorf( ( iRect.size.height - rect.size.height ) / 2.0 );
    rect.size.width = bigWidth;
    
    BOOL flag = NO;
    for (int i = 0; i < self.numberOfPages; ++i ) {
        if (i == self.currentPage) {
            if (_imagePageStateHighlighted) {
                image = _imagePageStateHighlighted;
            }
            else {
                flag = YES;
            }
        }
        else {
            if (_imagePageStateNormal) {
                image = _imagePageStateNormal;
            }
            else {
                flag = YES;
            }
        }
        
        if (flag) {
            float deltaX = (rect.size.width - [[self.subviews objectAtIndex:i] frame].size.width) / 2;
            float deltaY = (rect.size.height - [[self.subviews objectAtIndex:i] frame].size.height) / 2;
            rect.origin.x += deltaX;
            rect.origin.y += deltaY;
            rect.size.width = [[self.subviews objectAtIndex:i] frame].size.width;
            rect.size.height = [[self.subviews objectAtIndex:i] frame].size.height;
            [[self.subviews objectAtIndex:i] setFrame:rect];
            rect.origin.x += rect.size.width + deltaX + _pageIndicatorSpacing;
            rect.origin.y -= deltaY;
            rect.size.width = bigWidth;
            rect.size.height = bigHeight;
            flag = NO;
        }
        
        else {
            [image drawInRect: rect];
            
            if ([[UIDevice currentDevice] systemVersion].floatValue < 6.0) {
                [[self.subviews objectAtIndex:i] setAlpha:0];
            }
            rect.origin.x += bigWidth + _pageIndicatorSpacing;
        }
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [super endTrackingWithTouch:touch withEvent:event];
    [self updatePageControl];
}

@end
