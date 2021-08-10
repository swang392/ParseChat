//
//  ChatViewController.m
//  ParseChat
//
//  Created by Sarah Wang on 7/6/21.
//

#import "ChatViewController.h"
#import "Parse/Parse.h"
#import "ChatCell.h"
#import "UIImageView+AFNetworking.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(requeryChatFeed) userInfo:nil repeats:true];
    [self requeryChatFeed];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.messages = [NSArray new];
    self.refreshControl = [UIRefreshControl new];
    
    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (IBAction)sendMessage:(id)sender {
    PFObject *chatMessage = [PFObject objectWithClassName:@"Message_FBU2021"];
    chatMessage[@"text"] = self.messageTextField.text;
    chatMessage[@"user"] = PFUser.currentUser;
    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            [self.messageTextField setText:@""];
        } else {
            //TODO: show error
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    
    PFObject *message = self.messages[indexPath.row];
    cell.messageLabel.text = message[@"text"];
    
    PFUser *user = message[@"user"];
    
    if (user != nil) {
        cell.userLabel.text = user.username;
    } else {
        cell.userLabel.text = @"Anonymous user";
    }
    
    NSString *baseURLString = @"https://api.hello-avatar.com/adorables/";
    NSURL *avatarURL = [NSURL URLWithString:[baseURLString stringByAppendingString:(user != nil ? user.username : @"default")]];
    [cell.avatarImageView setImageWithURL:avatarURL];
    return cell;
}

- (void)requeryChatFeed {
    PFQuery *query = [PFQuery queryWithClassName:@"Message_FBU2021"];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.messages = posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)refreshFeed {
    [self requeryChatFeed];
    [self.refreshControl endRefreshing];
}

@end
