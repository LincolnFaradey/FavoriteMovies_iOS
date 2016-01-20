//
//  AppDelegate.m
//  FavoriteMovieApp
//
//  Created by Andrei Nechaev on 1/18/16.
//  Copyright © 2016 Nechaev. All rights reserved.
//

#import "AppDelegate.h"
#import "ANCoreDataStack.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _coreDataStack = [[ANCoreDataStack alloc] init];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self.coreDataStack saveContext];
}

@end
