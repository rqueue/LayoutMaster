#import "ViewController.h"
#import "FlowMaster.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *h1 = [UIView new];
    h1.backgroundColor = [UIColor brownColor];
    UIView *h2 = [UIView new];
    h2.backgroundColor = [UIColor whiteColor];
    NSDictionary *hv = NSDictionaryOfVariableBindings(h1, h2);

    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor blueColor];
    UIView *view2 = [FlowMaster viewFromVisualFormats:@[@"[h1](15)",
                                                        @"[h2](15)"]
                                     variableBindings:hv];
    view2.backgroundColor = [UIColor greenColor];
    UIView *view3 = [[UIView alloc] init];
    view3.backgroundColor = [UIColor redColor];
    UIView *view4 = [[UIView alloc] init];
    view4.backgroundColor = [UIColor orangeColor];
    UIView *view5 = [[UIView alloc] init];
    view5.backgroundColor = [UIColor redColor];
    UIView *view6 = [[UIView alloc] init];
    view6.backgroundColor = [UIColor orangeColor];

    NSDictionary *variables = NSDictionaryOfVariableBindings(view1, view2, view3, view4, view5, view6);
    UIView *containerView = [FlowMaster viewFromVisualFormats:@[@"[view1(23)][view2](45)",
                                                                @"[view3][view4(22)](90)",
                                                                @"[view5(60)][view6(100)](200)"]
                                             variableBindings:variables];

    containerView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:containerView];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:containerView.frame.size.height]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:containerView.frame.size.width]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

@end
