//
//  LoginViewController.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "LoginViewController.h"
#import "CNFLog.h"

@interface LoginViewController ()
{
	__weak IBOutlet UITextField				*_email;
	__weak IBOutlet UITextField				*_password;
	__weak IBOutlet UIActivityIndicatorView	*_progress;
	__weak IBOutlet UIButton				*_login;
	__weak IBOutlet UIButton				*_registration;
}

@end

#define EMULATE_INFO

@implementation LoginViewController

-(void)serverError:(NSError *)error {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
																   message:error.domain
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction	*action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
													 style:UIAlertActionStyleDefault
												   handler:nil];
	[alert addAction:action];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)serverLoginReady:(NSString *)token {
	[self performSegueWithIdentifier:@"sw_login" sender:nil];
}

- (IBAction)_handleLogin:(id)sender {
	CNFLog(@"");
	
	CNFParser *parser = [CNFParser sharedInstance];
	[parser login:_email.text password:_password.text];
	
	[_progress startAnimating];
	
	// DEBUG
	//[self performSegueWithIdentifier:@"sw_login" sender:nil];
}

- (IBAction)_handleRegistration:(id)sender {
	CNFLog(@"");
	
	[self performSegueWithIdentifier:@"sw_l2r" sender:nil];
}

- (void)_customSetup {
	CNFLog(@"");
	
	CNFParser *parser = [CNFParser sharedInstance];
	[parser addDelegate:self];

#ifdef EMULATE_INFO
	_email.text		= [NSString stringWithFormat:@"user1@m.ru"];
	_password.text	= [NSString stringWithFormat:@"123456"];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self _customSetup];
}

-(void)dealloc {
	CNFLog(@"");
	
	CNFParser *parser = [CNFParser sharedInstance];
	[parser removeDelegate:self];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	if(touch.phase==UITouchPhaseBegan){
		//find first response view
		for (UIView *view in [self.view subviews]) {
			if ([view isFirstResponder]) {
				[view resignFirstResponder];
				break;
			}
		}
	}
}

@end
