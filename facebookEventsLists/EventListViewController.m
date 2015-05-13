//
//  EventListViewController.m
//  facebookEventsLists
//
//  Created by Daniel K. Poulsen on 25/04/15.
//  Copyright (c) 2015 Daniel K. Poulsen. All rights reserved.
//

#import "EventListViewController.h"
#import "AttendingViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "EventMeta.h"

@interface EventListViewController ()
@property NSMutableArray *arrayOfMetaEvents;
@end
long selected;

@implementation EventListViewController

- (void)viewDidLoad {
    __block UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(self.view.frame.size.width/2 - 48, self.view.frame.size.height/2 - 48, 48, 48);
    [self.view addSubview:spinner];
    [spinner startAnimating];
    self.arrayOfMetaEvents = [[NSMutableArray alloc] init];
    [FBRequestConnection startWithGraphPath:@"me/events/?limit=200"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error == nil) {
                                  NSLog(@"3 %@",result);
                                  NSArray *arrayOfDict = [result valueForKey:@"data"];
                                  for (NSDictionary *dic in arrayOfDict) {
                                      EventMeta *event = [[EventMeta alloc] init];
                                      for (NSString *key in dic) {
                                          if ([event respondsToSelector:NSSelectorFromString(key)]) {
                                              [event setValue:[dic valueForKey:key] forKey:key];
                                          }
                                      }
                                      [self.arrayOfMetaEvents addObject:event];
                                  }
                                  NSLog(@"done");
                                  [self.tableView reloadData];
                              }else{
                                  NSLog(@"error: %@", error);
                              }
                              [spinner stopAnimating];
                          }];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfMetaEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"testCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"testCell"];
    }    EventMeta *event = self.arrayOfMetaEvents[indexPath.row];
    cell.textLabel.text = event.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EventMeta *event = self.arrayOfMetaEvents[indexPath.row];
    selected = event.id;
    [self performSegueWithIdentifier:@"showAttending" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAttending"]) {
        AttendingViewController *vc = [segue destinationViewController];
        vc.eventID = selected;
    }
    
}


@end
