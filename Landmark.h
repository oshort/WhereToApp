//
//  Landmark.h
//  WhereTo
//
//  Created by Oliver Short on 4/27/16.
//  Copyright © 2016 Oliver Short. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Landmark : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; //no pointer *, so it is a value type

@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;


//Below we are creating a new instance type for coordinates that can allow the title and subtitle to be edited
-(nullable instancetype)initWithCoord:(CLLocationCoordinate2D) coord title: (nullable NSString*) titleString subtitle: (nullable NSString*) subtitleString ;

@end
