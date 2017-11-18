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

@implementation LoginViewController

- (IBAction)_handleLogin:(id)sender {
	CNFLog(@"");
	
	[self performSegueWithIdentifier:@"sw_login" sender:nil];
}

- (IBAction)_handleRegistration:(id)sender {
	CNFLog(@"");
}

- (void)_customSetup {
	CNFLog(@"");
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self _customSetup];
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
