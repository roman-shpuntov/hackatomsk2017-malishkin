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
#import "CNFColor.h"

@interface GameInfoViewController () {
	__weak IBOutlet	UILabel		*_nickname;
	__weak IBOutlet UITableView	*_menu;
	
	NSArray						*_items;
}

@end

@implementation GameInfoViewController

- (void)_customSetup {
	CNFLog(@"");
	
	_menu.allowsSelection = NO;
	
	CNFParser *parser = [CNFParser sharedInstance];
	[parser addDelegate:self];
	_nickname.text = parser.user;
	
	_items = @[@"id_help", @"id_profile", @"id_settings", @"id_logout"];
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
	
	CNFParser *parser = [CNFParser sharedInstance];
	[parser startGame];
	
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString		*cellid	= [_items objectAtIndex:indexPath.row];
	UITableViewCell	*cell	= [tableView dequeueReusableCellWithIdentifier:cellid];
	
	if (!cell || !cell.detailTextLabel)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if ([cellid isEqualToString:@"id_help"])
		cell.textLabel.text = NSLocalizedString(@"How to play", nil);
	else if ([cellid isEqualToString:@"id_profile"]) {
		cell.textLabel.text = NSLocalizedString(@"Profile", nil);
		cell.detailTextLabel.text = @"120 credits";
		cell.detailTextLabel.textColor = [CNFColor purpleColor];
	}
	else if ([cellid isEqualToString:@"id_settings"])
		cell.textLabel.text = NSLocalizedString(@"Settings", nil);
	else if ([cellid isEqualToString:@"id_logout"]) {
		cell.textLabel.text = NSLocalizedString(@"Logout", nil);
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _items.count;
}

@end
