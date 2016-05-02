//
//  CardGameHistoryViewController.m
//  Matchismo
//
//  Created by Marcelo Gobetti on 2/5/14.
//  Copyright (c) 2014 Stanford. All rights reserved.
//

#import "GameHistoryViewController.h"

@interface GameHistoryViewController ()
@property (strong, nonatomic) IBOutlet UITextView *historyTextView;
@end

@implementation GameHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.historyTextView.attributedText = self.history;
}

@end
