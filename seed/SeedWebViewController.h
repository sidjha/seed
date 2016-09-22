//
//  SeedWebViewController.h
//  seed
//
//  Created by Sid Jha on 2016-09-17.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeedWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *seedWebView;
@property (nonatomic, strong) NSURL *urlToLoad;

@end
