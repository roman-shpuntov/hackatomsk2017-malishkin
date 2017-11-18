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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)_handleBack:(id)sender {
	CNFLog(@"");
}

- (IBAction)_handleRegister:(id)sender {
	CNFLog(@"");
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
