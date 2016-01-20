//
//  Image.h
//  FavoriteMovieApp
//
//  Created by Andrei Nechaev on 1/18/16.
//  Copyright © 2016 Nechaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Movie;

NS_ASSUME_NONNULL_BEGIN

@interface Image : NSManagedObject

@property (nullable, nonatomic, retain) NSData *background;
@property (nullable, nonatomic, retain) Movie *movie;

@end

NS_ASSUME_NONNULL_END

