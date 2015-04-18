#import "ViewController.h"
#import "FlowMaster.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    UIView *h1 = [UIView new];
//    h1.backgroundColor = [UIColor brownColor];
//    UIView *h2 = [UIView new];
//    h2.backgroundColor = [UIColor whiteColor];
//    NSDictionary *hv = NSDictionaryOfVariableBindings(h1, h2);
//
//    UIView *view1 = [[UIView alloc] init];
//    view1.backgroundColor = [UIColor blueColor];
//    UIView *view2 = [FlowMaster viewFromVisualFormats:@[@"[h1]",
//                                                        @"[h2](10)"]
//                                     variableBindings:hv];
//    view2.backgroundColor = [UIColor greenColor];
//    UIView *view3 = [[UIView alloc] init];
//    view3.backgroundColor = [UIColor redColor];
//    UIView *view4 = [[UIView alloc] init];
//    view4.backgroundColor = [UIColor orangeColor];
//    UIView *view5 = [[UIView alloc] init];
//    view5.backgroundColor = [UIColor redColor];
//    UIView *view6 = [[UIView alloc] init];
//    view6.backgroundColor = [UIColor orangeColor];
//
//    NSDictionary *variables = NSDictionaryOfVariableBindings(view1, view2, view3, view4, view5, view6);
//    UIView *containerView = [FlowMaster viewFromVisualFormats:@[@"[view1(23)][view2](45)",
//                                                                @"[view3][view4(22)](90)",
//                                                                @"[view5(60)][view6(100)](200)"]
//                                             variableBindings:variables];

    UIColor *sizeColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];

    UIImageView *p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Person"]];
    p.backgroundColor = sizeColor;

    UILabel *title = [UILabel new];
    title.font = [UIFont fontWithName:@"Arial-Bold" size:17.0];
    title.text = @"Here is the title";
    title.backgroundColor = sizeColor;

    UILabel *sub = [UILabel new];
    sub.font = [UIFont fontWithName:@"Arial" size:13.0];
    sub.text = @"Subtext description here";
    sub.backgroundColor = sizeColor;

    NSDictionary *tv = NSDictionaryOfVariableBindings(title, sub);
    UIView *text = [FlowMaster viewFromVisualFormats:@[@"[title](21)",
                                                       @"[sub]"]
                                    variableBindings:tv];

    UITextView *body = [UITextView new];
    body.backgroundColor = sizeColor;
    body.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    body.text = @"Here is some text that should be displayed in the body of this view. It should span multiple lines.";

    UIButton *b1 = [[UIButton alloc] init];
    [b1 setTitle:@"Agree" forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    b1.backgroundColor = sizeColor;
    UIButton *b2 = [[UIButton alloc] init];
    [b2 setTitle:@"Disagree" forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    b2.backgroundColor = sizeColor;
    UIButton *b3 = [[UIButton alloc] init];
    [b3 setTitle:@"Unsure" forState:UIControlStateNormal];
    [b3 setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    b3.backgroundColor = sizeColor;

    NSDictionary *cv = NSDictionaryOfVariableBindings(p, text, body, b1, b2, b3);
    UIView *card = [FlowMaster viewFromVisualFormats:@[@"[p(48)][text](48)",
                                                       @"[body]",
                                                       @"[b1(==)][b2(==)][b3(==)](40)"]
                                    variableBindings:cv];


    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 350.0, 218.0)];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 3.0;
    containerView.layer.borderWidth = 1.0;
    containerView.layer.borderColor = [UIColor blackColor].CGColor;
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


    [containerView addSubview:card];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[c]-15-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"c": card}]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[c]-15-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"c": card}]];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

@end
