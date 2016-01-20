//
//  Movie.h
//  FavoriteMovieApp
//
//  Created by Andrei Nechaev on 1/18/16.
//  Copyright © 2016 Nechaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Movie : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *details;
@property (nullable, nonatomic, retain) NSNumber *rating;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSNumber *movieID;
@property (nullable, nonatomic, retain) NSData *poster;
@property (nullable, nonatomic, retain) NSString *posterLink;
@property (nullable, nonatomic, retain) NSString *backgroundLink;
@property (nullable, nonatomic, retain) NSManagedObject *backroundImage;

- (instancetype)initWith:(NSDictionary *)dict context:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

