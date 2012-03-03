//
//  FaceView.m
//  Happiness
//
//  Created by Andrey Poznyak on 3/3/12.
//  Copyright (c) 2012 bsuir. All rights reserved.
//

#import "FaceView.h"

#define DEFAULT_SCALE 0.90

@implementation FaceView

@synthesize scale = _scale;
@synthesize dataSource = _dataSource;

- (CGFloat)scale
{
    if(!_scale) return DEFAULT_SCALE;
    else return _scale;
}

- (void)setScale:(CGFloat)scale
{
    if(_scale != scale)
    {
        _scale = scale;
        [self setNeedsDisplay];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if((gesture.state == UIGestureRecognizerStateChanged) ||
       (gesture.state == UIGestureRecognizerStateEnded)){
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES);
    CGContextStrokePath(context);    
    UIGraphicsPopContext();
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //face
    CGPoint midPoint;
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    
    CGFloat size = self.bounds.size.width / 2;
    if(self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height / 2;
    size *= self.scale;
    
    CGContextSetLineWidth(context, 5.0);
    [[UIColor blueColor] setStroke];
    
    [self drawCircleAtPoint:midPoint withRadius:size inContext:context];
    
    //eyes
    CGPoint eyePoint;
    eyePoint.x = midPoint.x - size * 0.35;
    eyePoint.y = midPoint.y - size * 0.35;
    
    [self drawCircleAtPoint:eyePoint withRadius:size*0.1 inContext:context];
    eyePoint.x = midPoint.x + size * 0.35;
    [self drawCircleAtPoint:eyePoint withRadius:size*0.1 inContext:context];
    
    //mouse
#define MOUSE_H 0.45
#define MOUSE_V 0.40
#define MOUSE_SMILE 0.25
    
    CGPoint mouseStart;
    mouseStart.x = midPoint.x - size * MOUSE_H;
    mouseStart.y = midPoint.y + size * MOUSE_V;
    CGPoint mouseEnd = mouseStart;
    mouseEnd.x += MOUSE_H * size * 2;
    CGPoint mouseCP1 = mouseStart;
    mouseCP1.x += MOUSE_H * size * 2/3;
    CGPoint mouseCP2 = mouseEnd;
    mouseCP2.x -= MOUSE_H * size * 2/3;
    
    float smile = [self.dataSource smileForFaceView:self];
    if(smile < -1) smile = -1;
    if(smile > 1) smile = 1;
    
    CGFloat smileOffset = smile * MOUSE_SMILE * size;
    mouseCP1.y += smileOffset;
    mouseCP2.y += smileOffset;

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, mouseStart.x, mouseStart.y);
    CGContextAddCurveToPoint(context, mouseCP1.x, mouseCP1.y, mouseCP2.x, mouseCP2.y, mouseEnd.x, mouseEnd.y);
    CGContextStrokePath(context);
}

@end
