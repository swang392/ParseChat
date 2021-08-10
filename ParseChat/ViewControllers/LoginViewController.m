//
//  LoginViewController.m
//  ParseChat
//
//  Created by Sarah Wang on 7/6/21.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIAlertController *emptyAlert;
@property (strong, nonatomic) UIAlertController *registerErrorAlert;
@property (strong, nonatomic) UIAlertController *loginErrorAlert;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emptyAlert = [UIAlertController alertControllerWithTitle:@"Username or password field empty" message:@"Please try again." preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // handle response here.
    }];
    [self.emptyAlert addAction:okAction];
    
    self.registerErrorAlert = [UIAlertController alertControllerWithTitle:@"Error registering user" message:@"Please try again." preferredStyle:(UIAlertControllerStyleAlert)];
    [self.registerErrorAlert addAction:okAction];
    
    self.loginErrorAlert = [UIAlertController alertControllerWithTitle:@"Error logging in user" message:@"Please try again." preferredStyle:(UIAlertControllerStyleAlert)];
    [self.loginErrorAlert addAction:okAction];
}

- (IBAction)registerUser:(id)sender {
    [self.activityIndicator startAnimating];
    
    if ([self.usernameTextField.text isEqual:@""] || [self.passwordTextField.text isEqual:@""]) {
        [self presentViewController:self.emptyAlert animated:YES completion:^{
            [self.activityIndicator stopAnimating];
        }];
    } else {
        PFUser *newUser = [PFUser user];
        
        newUser.username = self.usernameTextField.text;
        newUser.password = self.passwordTextField.text;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                [self presentViewController:self.registerErrorAlert animated:YES completion:^{
                    [self.activityIndicator stopAnimating];
                }];
            } else {
                [self.activityIndicator stopAnimating];
            }
        }];
    }
}

- (IBAction)loginUser:(id)sender {
    [self.activityIndicator startAnimating];
    
    if ([self.usernameTextField.text isEqual:@""] || [self.passwordTextField.text isEqual:@""]) {
        [self presentViewController:self.emptyAlert animated:YES completion:^{
            [self.activityIndicator stopAnimating];
        }];
    } else {
        NSString *username = self.usernameTextField.text;
        NSString *password = self.passwordTextField.text;
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                NSLog(@"User log in failed: %@", error.localizedDescription);
                [self presentViewController:self.loginErrorAlert animated:YES completion:^{
                    [self.activityIndicator stopAnimating];
                }];
            } else {
                NSLog(@"User logged in successfully");
                [self.activityIndicator stopAnimating];
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            }
        }];
    }
}

@end
