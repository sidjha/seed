//
//  IntroViewController.m
//  seed
//
//  Created by Sid Jha on 2016-10-06.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "IntroViewController.h"
#import "EAIntroView.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Hello world";
    page1.desc = @"Welcome to seed. IT is awesome.";

    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"Second page";
    page2.desc = @"You've reached page 2 of the tutorial.";

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2]];

    intro.delegate = self;

    intro.backgroundColor = [UIColor colorWithRed:0.f green:0.49f blue:0.96f alpha:1.f];

    [intro showInView:self.view animateDuration:0.0];

}

- (void)introDidFinish:(EAIntroView *)introView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *myController = [storyboard instantiateViewControllerWithIdentifier:@"rootVC"];
    [self presentViewController:myController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
