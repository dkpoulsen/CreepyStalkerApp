//
//  LoginViewController.m
//  DODO
//
//  Created by Daniel K. Poulsen on 24/10/14.
//  Copyright (c) 2014 Daniel K. Poulsen. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fbLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_events"];
    self.fbLoginButton.delegate = self;
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSUserDefaults *stored = [NSUserDefaults standardUserDefaults];
    
    NSString *token = [[[FBSession activeSession] accessTokenData] accessToken];
    NSString *fbID = user.objectID;
    
    [stored setObject:user.name forKey:@"username"];
    [stored setObject:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user.id] forKey:@"userpic"];
    [stored setObject:token forKey:@"token"];
    [stored setObject:fbID forKey:@"id"];
    [self performSegueWithIdentifier:@"showEvents" sender:self];
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {

}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


@end
