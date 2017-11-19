//
//  GameViewController.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "CNFParser.h"
#import "CNFLog.h"
#import "GameInfoViewController.h"

@interface GameViewController() {
	__weak IBOutlet UILabel					*_name;
	__weak IBOutlet	UIActivityIndicatorView	*_progress;
}

@end

@implementation GameViewController

-(void)serverStepWait {
	CNFLog(@"");
	[_progress stopAnimating];
}

-(void)serverStepReady {
	CNFLog(@"");
	[_progress startAnimating];
}

-(void)serverGameReady:(NSString *)userName {
	CNFLog(@"user %@", userName);
	
	_name.text = [NSString stringWithFormat:@"Name: %@", userName];
	[_progress stopAnimating];
}

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

- (void)_customSetup {
	CNFParser *parser = [CNFParser sharedInstance];
	[parser addDelegate:self];
	
	// Load 'GameScene.sks' as a GKScene. This provides gameplay related content
	// including entities and graphs.
	GKScene *scene = [GKScene sceneWithFileNamed:@"GameScene"];
	
	// Get the SKScene from the loaded GKScene
	GameScene *sceneNode = (GameScene *)scene.rootNode;
	
	// Copy gameplay related content over to the scene
	sceneNode.entities = [scene.entities mutableCopy];
	sceneNode.graphs = [scene.graphs mutableCopy];
	
	// Set the scale mode to scale to fit the window
	sceneNode.scaleMode = SKSceneScaleModeAspectFill;
	
	SKView *skView = (SKView *)self.view;
	
	// Present the scene
	[skView presentScene:sceneNode];
	
	//skView.showsFPS = YES;
	//skView.showsNodeCount = YES;
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

- (IBAction)_handleEnd:(id)sender {
	CNFLog(@"");
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"End game", nil)
																   message:NSLocalizedString(@"End game or logout?", nil)
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"End", nil)
														style:UIAlertActionStyleDefault
													  handler:^(UIAlertAction * action) {
														  CNFLog(@"end");
														  [self dismissViewControllerAnimated:YES completion:nil];
													  }];
	[alert addAction:yesAction];
	
	UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil)
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction * action) {
														 CNFLog(@"logout");
														 CNFParser	*parser = [CNFParser sharedInstance];
														 [parser logout];
														 
														 [self dismissViewControllerAnimated:YES completion:^{
															 [self.prevViewController dismissViewControllerAnimated:YES completion:nil];
														 }];
													 }];
	[alert addAction:noAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
