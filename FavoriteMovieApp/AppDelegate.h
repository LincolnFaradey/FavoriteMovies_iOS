//
//  AppDelegate.h
//  FavoriteMovieApp
//
//  Created by Andrei Nechaev on 1/18/16.
//  Copyright © 2016 Nechaev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ANCoreDataStack;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ANCoreDataStack *coreDataStack;
@end

