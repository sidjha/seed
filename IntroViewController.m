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
    page1.title = @"Discover what's \ntrending nearby.";
    page1.desc = @"Seeds are interesting links from \npeople currently nearby.";
    page1.titleColor = [UIColor blackColor];
    page1.titleFont = [UIFont fontWithName:@"Georgia-Bold" size:20];
    page1.titlePositionY = 240;
    page1.descPositionY = 220;

    page1.descColor = [UIColor blackColor];
    page1.descFont = [UIFont fontWithName:@"Georgia" size:16];

    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"Become a local curator.";
    page2.desc = @"Curate articles and videos \nfor people around you.";
    page2.titleColor = [UIColor blackColor];
    page2.titleFont = [UIFont fontWithName:@"Georgia-Bold" size:20];
    page2.descColor = [UIColor blackColor];
    page2.descFont = [UIFont fontWithName:@"Georgia" size:16];

    page2.titlePositionY = 240;
    page2.descPositionY = 220;

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2]];

    intro.delegate = self;

    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
    intro.titleView = titleView;
    intro.titleViewY = 90;

    intro.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    intro.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    intro.pageControlY = 110.f;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(0, 0, 80, 40)];
    [btn setTitle:@"SKIP" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.layer.borderWidth = 1.f;
    btn.layer.cornerRadius = 10;
    btn.layer.borderColor = [[UIColor blackColor] CGColor];
    intro.skipButton = btn;
    intro.skipButtonY = 70.f;
    intro.skipButtonAlignment = EAViewAlignmentCenter;


    intro.backgroundColor = [UIColor whiteColor];

    [intro showInView:self.view animateDuration:0.0];
}

- (void)introDidFinish:(EAIntroView *)introView wasSkipped:(BOOL)wasSkipped {
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
