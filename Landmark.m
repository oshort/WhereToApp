//
//  Landmark.m
//  WhereTo
//
//  Created by Oliver Short on 4/27/16.
//  Copyright © 2016 Oliver Short. All rights reserved.
//

#import "Landmark.h"

@implementation Landmark

//copy/paste, type init, copy the guts, paste below

-(nullable instancetype)initWithCoord:(CLLocationCoordinate2D) coord
                                title: (nullable NSString*) titleString
                             subtitle: (nullable NSString*) subtitleString
//read only properties can't be defined as self
{
    self = [super init];
    if (self) {
        _coordinate = coord;
        _title = titleString;
        _subtitle = subtitleString;
    }
    return self;
}

@end
