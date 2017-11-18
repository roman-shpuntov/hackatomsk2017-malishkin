//
//  RegistrationViewController.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "RegistrationViewController.h"
#import "CNFLog.h"

@interface RegistrationViewController ()
{
	__weak IBOutlet UITextField				*_name;
	__weak IBOutlet UITextField				*_email;
	__weak IBOutlet UITextField				*_password;
	__weak IBOutlet UIActivityIndicatorView	*_progress;
	__weak IBOutlet UIButton				*_backLogin;
	__weak IBOutlet UIButton				*_doRegister;
}

@end

@implementation RegistrationViewController

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

-(void)serverLoginReady:(NSString *)token channel:(NSString *)channel {
	[self performSegueWithIdentifier:@"sw_register" sender:nil];
}

- (void) _customSetup {
	_progress.hidden = YES;
	
	CNFParser *parser = [CNFParser sharedInstance];
	[parser addDelegate:self];
	
#ifdef EMULATE_INFO
	srand((unsigned int) time(NULL));
	
	_name.text		= [NSString stringWithFormat:@"name%d", rand() % 0x10000];
	_email.text		= [NSString stringWithFormat:@"user%d@m.ru", rand() % 0x10000];
	_password.text	= [NSString stringWithFormat:@"%08X", rand()];
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

- (IBAction)_handleBack:(id)sender {
	CNFLog(@"");
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)_handleRegister:(id)sender {
	CNFLog(@"");
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Registration", nil)
																   message:NSLocalizedString(@"Are you have already 18 years old?", nil)
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
														style:UIAlertActionStyleDefault
													  handler:^(UIAlertAction * action) {

														  CNFParser *parser = [CNFParser sharedInstance];
														  [parser registration:_name.text email:_email.text password:_password.text];
													  }];
	[alert addAction:yesAction];
	
	UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction * action) {
													 }];
	
	[alert addAction:noAction];
	[self presentViewController:alert animated:YES completion:nil];
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
