//
//  AttendingViewController.m
//  facebookEventsLists
//
//  Created by Daniel K. Poulsen on 26/04/15.
//  Copyright (c) 2015 Daniel K. Poulsen. All rights reserved.
//

#import "AttendingViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Person.h"

@interface AttendingViewController ()
@property NSMutableArray *arrayOfAttending;
@property NSMutableArray *filteredAttending;

@end

@implementation AttendingViewController
UIActivityIndicatorView *spinner;
NSString *graphString;

- (void)viewDidLoad {
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(self.view.frame.size.width/2 - 48, self.view.frame.size.height/2 - 48, 48, 48);
    [self.view addSubview:spinner];
    graphString = [NSString stringWithFormat:@"%ld/attending?limit=5000",self.eventID];
    self.arrayOfAttending = [[NSMutableArray alloc] init];
    self.filteredAttending = [[NSMutableArray alloc] init];
    [self fecthAttending];
    
}

-(void)fecthAttending{
    [spinner startAnimating];
    NSLog(@"new session");
    [FBRequestConnection startWithGraphPath:graphString
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error == nil) {
                                  //NSLog(@"%@",result);
                                  NSArray *arrayOfDict = [result valueForKey:@"data"];
                                  NSDictionary *paging = [result valueForKey:@"paging"];
                                  NSDictionary *cursors = [paging valueForKey:@"cursors"];
                                  NSString *after = [cursors valueForKey:@"after"];
                                  for (NSDictionary *dic in arrayOfDict) {
                                      Person *person = [[Person alloc] init];
                                      for (NSString *key in dic) {
                                          if ([person respondsToSelector:NSSelectorFromString(key)]) {
                                              [person setValue:[dic valueForKey:key] forKey:key];
                                          }
                                      }
                                      [self.arrayOfAttending addObject:person];
                                  }
                                  NSLog(@"done");
                                  self.filteredAttending = [NSMutableArray arrayWithArray:self.arrayOfAttending];
                                  [self.tableView reloadData];
                                  if (arrayOfDict.count == 5000) {
                                      sleep(1);
                                      graphString = [NSString stringWithFormat:@"%ld/attending?limit=5000&after=%@",self.eventID, after];
                                      [self fecthAttending];
                                  }else{
                                      [spinner stopAnimating];
                                  }
                                  
                              }else{
                                  NSLog(@"error: %@", error);
                                  [self fecthAttending];
                              }
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
    self.title = [NSString stringWithFormat:@"%ld", self.filteredAttending.count];
    return self.filteredAttending.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"testCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"testCell"];
    }    Person *person = self.filteredAttending[indexPath.row];
    cell.textLabel.text = person.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Person *person = self.filteredAttending[indexPath.row];
    NSString *url = [NSString stringWithFormat:@"https://www.facebook.com/app_scoped_user_id/%ld/", person.id];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![searchBar.text  isEqual: @""]) {
        self.filteredAttending = [[NSMutableArray alloc] init];
        for (Person *p in self.arrayOfAttending) {
            if ([p.name containsString:searchBar.text]) {
                [self.filteredAttending addObject:p];
            }
        }
    }else{
        self.filteredAttending = self.arrayOfAttending;
    }
    [self.tableView reloadData];
}


- (void)startSearch:(NSString *)searchString
{

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


@end
