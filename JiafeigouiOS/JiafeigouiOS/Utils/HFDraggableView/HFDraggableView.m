//
//  HFDraggableView.m
//  HFDraggableView
//
//  Created by Henry on 08/11/2017.
//  Copyright © 2017 Henry. All rights reserved.
//

#import "HFDraggableView.h"
#import "HFDragHandle.h"
#import "HFAngleIndicator.h"
#import "UIView+HFFoundation.h"

static const CGFloat kHandleWH = 20;
static const CGFloat kRotateHandleDistance = 40;

@implementation HFDraggableView {
    HFDragHandle *_tlZoomHandle;
    HFDragHandle *_trZoomHandle;
    HFDragHandle *_blZoomHandle;
    HFDragHandle *_brZoomHandle;
    HFAngleIndicator *_rotateIndicator;
    CAShapeLayer *_rotateLine;
    UIPanGestureRecognizer *_panOnView;
    
    CGPoint _initialPoint;
    CGFloat _initialAngle;
}

#pragma mark- lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    _tlZoomHandle = [self createZoomHandle];
    _trZoomHandle = [self createZoomHandle];
    _blZoomHandle = [self createZoomHandle];
    _brZoomHandle = [self createZoomHandle];
    //_rotateIndicator = [self createRotateIndicator];
    //_rotateLine = [self createRotateLine];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)]];
    _panOnView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanView:)];
    _panOnView.enabled = NO;
    [self addGestureRecognizer:_panOnView];

    self.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [self setActive:NO];
    
    return self;
}

- (void)didMoveToSuperview {
    [_tlZoomHandle removeFromSuperview];
    [_trZoomHandle removeFromSuperview];
    [_blZoomHandle removeFromSuperview];
    [_brZoomHandle removeFromSuperview];
    [_rotateIndicator removeFromSuperview];
    
    [self.superview addSubview:_tlZoomHandle];
    [self.superview addSubview:_trZoomHandle];
    [self.superview addSubview:_blZoomHandle];
    [self.superview addSubview:_brZoomHandle];
    //[self.superview addSubview:_rotateIndicator];
    //[self.layer addSublayer:_rotateLine];
    self.transform = CGAffineTransformMakeRotation(self.angle);
}

#pragma mark- public M
+ (void)setActiveView:(HFDraggableView *)view {
    static HFDraggableView *activeView = nil;
    if (![view isEqual:activeView]) {
        [activeView setActive:NO];
        activeView = view;
        [activeView setActive:YES];
    }
}

#pragma mark- event
- (void)didTapView:(UITapGestureRecognizer *)tap {
    [[self class] setActiveView:self];
}

- (void)didPanView:(UIPanGestureRecognizer *)pan {
    CGPoint p = [pan translationInView:self.superview];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    [self refreshHandles];
}

- (void)didPanZoomHandle:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    UIView *targetView = pan.view;
    
    if ([targetView isEqual:_tlZoomHandle]) {
        if (pan.state == UIGestureRecognizerStateBegan) {
            [self hf_setAnchorPoint:CGPointMake(1, 1)];
        }
        CGRect bounds = self.bounds;
        bounds.size.width = MAX(bounds.size.width - translation.x, kHandleWH);
        bounds.size.height = MAX(bounds.size.height - translation.y, kHandleWH);
        self.bounds = bounds;
    } else if ([targetView isEqual:_blZoomHandle]) {
        if (pan.state == UIGestureRecognizerStateBegan) {
            [self hf_setAnchorPoint:CGPointMake(1, 0)];
        }
        CGRect bounds = self.bounds;
        bounds.size.width = MAX(bounds.size.width - translation.x, kHandleWH);
        bounds.size.height = MAX(bounds.size.height + translation.y, kHandleWH);
        self.bounds = bounds;
    } else if ([targetView isEqual:_brZoomHandle]) {
        if (pan.state == UIGestureRecognizerStateBegan) {
            [self hf_setAnchorPoint:CGPointMake(0, 0)];
        }
        CGRect bounds = self.bounds;
        bounds.size.width = MAX(bounds.size.width + translation.x, kHandleWH);
        bounds.size.height = MAX(bounds.size.height + translation.y, kHandleWH);
        self.bounds = bounds;
    } else if ([targetView isEqual:_trZoomHandle]) {
        if (pan.state == UIGestureRecognizerStateBegan) {
            [self hf_setAnchorPoint:CGPointMake(0, 1)];
        }
        CGRect bounds = self.bounds;
        bounds.size.width = MAX(bounds.size.width + translation.x, kHandleWH);
        bounds.size.height = MAX(bounds.size.height - translation.y, kHandleWH);
        self.bounds = bounds;
    }
    
    [pan setTranslation:CGPointZero inView:self];
    [self refreshHandles];
    [self refreshRoateLine];
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self hf_setAnchorPoint:CGPointMake(0.5, 0.5)];
    }
}

- (void)didPanRotateHandle:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:pan.view.superview];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _initialPoint = pan.view.center;
        _initialAngle = self.angle;
    }
    
    CGFloat startAngle = atan2(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
    CGFloat endAngle = atan2(point.x - self.center.x, point.y - self.center.y);
    
    _initialAngle += (startAngle - endAngle);
    _initialPoint = point;
    
    if (fabs(fmodf(_initialAngle, M_PI_2)) < M_PI/90) {
        self.transform = CGAffineTransformMakeRotation((int)(_initialAngle / M_PI_2) * M_PI_2);
        _rotateIndicator.angle = (int)(_initialAngle / M_PI_2) * M_PI_2;
        self.angle = _rotateIndicator.angle;
    } else {
        self.transform = CGAffineTransformMakeRotation(_initialAngle);
        _rotateIndicator.angle = _initialAngle;
        self.angle = _initialAngle;
    }
    
    [self refreshHandles];
}

#pragma mark- private M
- (HFDragHandle *)createZoomHandle {
    HFDragHandle *handle = [[HFDragHandle alloc] initWithFrame:CGRectMake(0, 0, kHandleWH, kHandleWH)];
    handle.color = [UIColor colorWithWhite:0.0 alpha:0.7];
    handle.scale = 0.7;
    handle.borderColor = [UIColor whiteColor];
    handle.borderWidth = 2.5;
    [handle addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(didPanZoomHandle:)]];
    handle.hidden = YES;
    return handle;
}

- (HFAngleIndicator *)createRotateIndicator {
    HFAngleIndicator *indicator = [[HFAngleIndicator alloc] init];
    [indicator addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(didPanRotateHandle:)]];
    indicator.hidden = YES;
    return indicator;
}

- (CAShapeLayer *)createRotateLine {
    CAShapeLayer *rotateLine = [CAShapeLayer layer];
    rotateLine.opacity = 0.0;
    return rotateLine;
}

- (void)refreshHandles {
    _tlZoomHandle.center = [self hf_topLeftVertex];
    _trZoomHandle.center = [self hf_topRightVertex];
    _blZoomHandle.center = [self hf_bottomLeftVertex];
    _brZoomHandle.center = [self hf_bottomRightVertex];
    _rotateIndicator.center = [self rotateHandleCenter];
}

- (void)refreshRoateLine {
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    [linePath moveToPoint:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)];
    [linePath addLineToPoint:CGPointMake(self.bounds.size.width / 2, -kRotateHandleDistance)];
    _rotateLine.path = linePath.CGPath;
    _rotateLine.fillColor = nil;
    _rotateLine.strokeColor = [[UIColor orangeColor] CGColor];
    _rotateLine.lineWidth = 2.0;
}

- (CGPoint)rotateHandleCenter {
    CGRect frame = self.hf_frame;
    CGPoint point = frame.origin;
    
    // origin center
    point.x += frame.size.width/2;
    point.y -= kRotateHandleDistance;
    
    // transformed center
    point.x -= self.center.x;
    point.y -= self.center.y;
    point = CGPointApplyAffineTransform(point, self.transform);
    point.x += self.center.x;
    point.y += self.center.y;
    
    return point;
}

#pragma mark- accessor

- (void)setActive:(BOOL)active {
    if (active) {
        [self refreshHandles];
        [self refreshRoateLine];
        _rotateIndicator.angle = self.angle;
    }
    self.layer.borderWidth = active ? 1: 0;
    _rotateLine.opacity = active ? 1.0 : 0.0;
    _panOnView.enabled = active;
    
    _tlZoomHandle.hidden = !active;
//    [_tlZoomHandle.superview bringSubviewToFront:_tlZoomHandle];
    _trZoomHandle.hidden = !active;
//    [_trZoomHandle.superview bringSubviewToFront:_trZoomHandle];
    _blZoomHandle.hidden = !active;
//    [_blZoomHandle.superview bringSubviewToFront:_blZoomHandle];
    _brZoomHandle.hidden = !active;
//    [_brZoomHandle.superview bringSubviewToFront:_brZoomHandle];
    _rotateIndicator.hidden = !active;
//    [_rotateIndicator.superview bringSubviewToFront:_rotateIndicator];
    
}

@end
