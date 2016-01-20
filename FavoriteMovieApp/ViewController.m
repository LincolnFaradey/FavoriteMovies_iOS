//
//  ViewController.m
//  FavoriteMovieApp
//
//  Created by Andrei Nechaev on 1/18/16.
//  Copyright © 2016 Nechaev. All rights reserved.
//

#import "ViewController.h"
#import "ANMovieCell.h"
#import "Movie.h"
#import "ANCoreDataStack.h"
#import "AppDelegate.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic) CGSize itemSize;
@property (strong, nonatomic) ANCoreDataStack *coreDataStack;
@property (strong, nonatomic) NSFetchedResultsController *fetchedController;

//@property (strong, nonatomic) NSURLSession *session;

@end
@implementation ViewController
@synthesize itemSize;

- (void)viewDidLoad {
    _coreDataStack = [(AppDelegate *)[[UIApplication sharedApplication] delegate] coreDataStack];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    itemSize = CGSizeMake(self.view.frame.size.width / 2. - 2, self.view.frame.size.height / 2.5);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                 ascending:YES];
    request.fetchBatchSize = 6;
    request.sortDescriptors = @[descriptor];
    
    _fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                             managedObjectContext:_coreDataStack.managedObjectContext
                                                               sectionNameKeyPath:nil
                                                                        cacheName:@"moviesCache"];
    self.fetchedController.delegate = self;
    
    NSURL *url = [self createURL];
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
//    _session = [NSURLSession sessionWithConfiguration:configuration];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data,
                                                                           NSURLResponse * _Nullable response,
                                                                           NSError * _Nullable error) {
        if (!error) {
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:nil];
            NSArray *movies = jsonResponse[@"results"];
            
            for (NSDictionary *movieDict in movies) {
                Movie *newMovie = [[Movie alloc] initWith:movieDict
                                                  context:self.coreDataStack.managedObjectContext];
                NSError *err = nil;
                if (!newMovie.poster) {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:newMovie.posterLink]
                                                              options:NSDataReadingMapped
                                                                error:&err];
                    newMovie.poster = imageData;
                }
                
                if (!err) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.coreDataStack saveContext];
                    });
                }else {
                    NSLog(@"error: %@", err.userInfo);
                }
            }
            
            
            NSLog(@"Response: %@", jsonResponse);
        }else {
            NSLog(@"Error: %@", error.userInfo);
        }
    }] resume];
    
    NSError *error;
    [self.fetchedController performFetch:&error];
    
    if (error) {
        NSLog(@"Fetched error = %@", error.userInfo);
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sections = self.fetchedController.sections[section];
    return [sections numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ANMovieCell *cell = (ANMovieCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"movieCell"
                                                                           forIndexPath:indexPath];
    Movie *movie = [self.fetchedController objectAtIndexPath:indexPath];
    
    cell.posterView.image = [UIImage imageWithData:movie.poster];
    
    return cell;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return itemSize;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (size.height > size.width) {
        itemSize = CGSizeMake(size.width / 2. - 2, size.height / 2.5);
    } else {
        itemSize = CGSizeMake(size.width / 3. - 3, size.width / 2.);
    }
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeUpdate:
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            break;
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
        default:
            break;
    }
}

#pragma mark - Helpers

- (Movie *)findOrCreateMovieWith:(NSNumber *)movieID
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Movie"
                                                  inManagedObjectContext:self.coreDataStack.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Movie"];
    request.predicate = [NSPredicate predicateWithFormat:@"movieID == %ld", movieID.integerValue];
    request.fetchLimit = 1;
    request.entity = entityDesc;
    
    NSError *err;
    NSArray *result = [self.coreDataStack.managedObjectContext executeFetchRequest:request
                                                                             error:&err];
    if (err) {
        NSLog(@"Error = %@", err.userInfo);
    }
    Movie *newMovie;
    if ([result count] == 0) {
        newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie"
                                                 inManagedObjectContext:self.coreDataStack.managedObjectContext];
        newMovie.movieID = movieID;
    } else {
        newMovie = result.firstObject;
    }
    
    return newMovie;
}

- (NSURL *)createURL
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"https";
    components.host = @"api.themoviedb.org";
    components.path = @"/3/discover/movie";
    
    NSURLQueryItem *apiKeyItem = [NSURLQueryItem queryItemWithName:@"api_key"
                                                             value:@"6c6886397668c3bd57d7f66a3ade3882"];
    NSURLQueryItem *sortingItem = [NSURLQueryItem queryItemWithName:@"sort_by"
                                                              value:@"popularity.desc"];
    components.queryItems = @[apiKeyItem, sortingItem];
    
    return components.URL;
}


@end
