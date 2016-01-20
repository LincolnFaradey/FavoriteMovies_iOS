//
//  Movie.m
//  FavoriteMovieApp
//
//  Created by Andrei Nechaev on 1/18/16.
//  Copyright © 2016 Nechaev. All rights reserved.
//

#import "Movie.h"

@implementation Movie

// Insert code here to add functionality to your managed object subclass
@dynamic name;
@dynamic details;
@dynamic rating;
@dynamic year;
@dynamic movieID;
@dynamic poster;
@dynamic posterLink;
@dynamic backgroundLink;
@dynamic backroundImage;

- (instancetype)initWith:(NSDictionary *)dict context:(NSManagedObjectContext *)context
{
    NSNumber *movieID = dict[@"id"];
    NSString *movieTitle = dict[@"title"];
    NSString *description = dict[@"overview"];
    NSString *path = dict[@"poster_path"];
    NSString *imageURLPath = [@"http://image.tmdb.org/t/p/w300" stringByAppendingString:path];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:[self entityName]
                                                  inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.predicate = [NSPredicate predicateWithFormat:@"movieID == %ld", movieID.integerValue];
    request.fetchLimit = 1;
    request.entity = entityDesc;
    
    NSError *err;
    NSArray *result = [context executeFetchRequest:request
                                             error:&err];
    if (err) {
        NSLog(@"Error = %@", err.userInfo);
    }

    if ([result count] == 0) {
        self = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                 inManagedObjectContext:context];
        self.movieID = movieID;
        self.name = movieTitle;
        self.details = description;
        self.posterLink = imageURLPath;
    } else {
        self = result.firstObject;
    }

    return self;
}

- ( NSString * _Nonnull )entityName
{
    return @"Movie";
}

@end
