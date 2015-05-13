//
//  AppDelegate.h
//  facebookEventsLists
//
//  Created by Daniel K. Poulsen on 25/04/15.
//  Copyright (c) 2015 Daniel K. Poulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;


@end

