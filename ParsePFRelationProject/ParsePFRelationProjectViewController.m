#import "ParsePFRelationProjectViewController.h"
#import <Parse/Parse.h>

@implementation ParsePFRelationProjectViewController


- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loadFollowingInMemory:(id)sender
{
  PFUser *mainUser = [[PFUser alloc] init];
  PFRelation *userFollowingRelation = [mainUser relationforKey:@"userFollowing"];
  
  self.mainLabel.text = @"Processing users";
  
  [[PFUser query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
      NSMutableArray *usersToAdd = [NSMutableArray arrayWithArray:objects];
      
      if (usersToAdd.count < 30)
      {
        @autoreleasepool
        {
          for (int i = 0; i < 30; i++)
          {
            PFUser *user = [[PFUser alloc] init];
            user.username = [NSString stringWithFormat:@"testemail%d", i + 1];
            user.email = [NSString stringWithFormat:@"%@@test.com", user.username];
            user.password = @"whatnightlivesinthatcastle?";
            [user.ACL setPublicReadAccess:YES];
            [user.ACL setPublicWriteAccess:YES];
            [user signUp];
            //          [user save];
            
            [usersToAdd addObject:user];
          }
        }
      }
      
      for (PFUser *user in usersToAdd)
      {
        [userFollowingRelation addObject:user];
      }
      
      dispatch_async(dispatch_get_main_queue(), ^{
        self.mainLabel.text = @"Processing users complete.\n\nCheck 'Cycles & Roots' in 'Instruments' > 'Leaks' for PFRelation leaks.";
      });
    });
  }];
}

@end
