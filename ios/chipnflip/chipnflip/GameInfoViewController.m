//
//  GameInfoViewController.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "GameInfoViewController.h"
#import "GameViewController.h"
#import "CNFLog.h"
#import "CNFParser.h"

@interface GameInfoViewController ()

@end

@implementation GameInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)_handleHelp:(id)sender {
	CNFLog(@"");
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Help", nil)
																   message:NSLocalizedString(@"Help info", nil)
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction * action) {
													 }];
	[alert addAction:noAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)_handlePlay:(id)sender {
	CNFLog(@"");
	
	[self performSegueWithIdentifier:@"sw_game" sender:nil];
}

- (IBAction)_handleSettings:(id)sender {
	CNFLog(@"");
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Settings", nil)
																   message:NSLocalizedString(@"Some settings", nil)
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction * action) {
													 }];
	[alert addAction:noAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)_handlePersonalInfo:(id)sender {
	CNFLog(@"");
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Personal info", nil)
																   message:NSLocalizedString(@"Info", nil)
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction * action) {
													 }];
	[alert addAction:noAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)_handleLogout:(id)sender {
	CNFLog(@"");
	
	CNFParser	*parser = [CNFParser sharedInstance];
	[parser logout];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	id dvc = [segue destinationViewController];
	
	if ([dvc isKindOfClass:[GameViewController class]]) {
		GameViewController *pvc = (GameViewController *) dvc;
		pvc.prevViewController = self;
	}
}

@end
