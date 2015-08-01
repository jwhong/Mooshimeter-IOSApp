//
//  MPBarsGraphView.h
//  MPPlot
//
//  Created by Alex Manzella on 22/05/14.
//  Copyright (c) 2014 mpow. All rights reserved.
//

#import "MPPlot.h"

@interface MPBarsGraphView : MPPlot{
    
    BOOL shouldAnimate;

}

@property (nonatomic, readwrite) CGFloat topCornerRadius;

@property (nonatomic, readwrite) NSArray* backValues; // background gray values - always be 0.2, 0.4, 0.6, 0.8, 1.0

@end
