//
//  SeedWebViewController.m
//  seed
//
//  Created by Sid Jha on 2016-09-17.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "SeedWebViewController.h"

@interface SeedWebViewController ()

@end

@implementation SeedWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.seedWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    self.seedWebView.delegate = self;

    NSURLRequest *request = [NSURLRequest requestWithURL:self.urlToLoad];

    [self.seedWebView loadRequest:request];

    [self.view addSubview:self.seedWebView];

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
