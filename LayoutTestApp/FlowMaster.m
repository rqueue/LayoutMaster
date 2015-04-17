#import "FlowMaster.h"
#import "FlowItem.h"

static CGFloat const kFlowMasterPadding = 15.0;

@implementation FlowMaster

+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats variableBindings:(NSDictionary *)variableBindings {
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;

    NSMutableArray *flowItemsRows = [NSMutableArray array];
    for (NSString *visualFormat in visualFormats) {
        NSArray *flowItems = [self flowItemsForVisualFormat:visualFormat variableBindings:variableBindings];
        [flowItemsRows addObject:flowItems];
    }

    CGFloat height = 0;
    CGFloat width = 0;

    for (NSUInteger row = 0; row < [flowItemsRows count]; row++) {
        if (row > 0) {
            height += kFlowMasterPadding;
        }

        CGFloat rowWidth = 0;
        NSArray *flowItems = flowItemsRows[row];
        for (NSUInteger i = 0; i < [flowItems count]; i++) {
            FlowItem *flowItem = flowItems[i];

            if (flowItem.widthType == FlowItemDimensionTypeFixed) {
                rowWidth += flowItem.width;
            }

            UIView *view = flowItem.view;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:view];

            // Vertical Constraints

            if (flowItem.heightType == FlowItemDimensionTypeFixed) {
                [containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:flowItem.height]];
            }
            
            if (row == 0) {
                // Constrain view to top
                [containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:containerView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            } else {
                // Constrain view to a view above
                FlowItem *aboveFlowItem = flowItemsRows[row - 1][0];
                UIView *aboveView = aboveFlowItem.view;
                [containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:aboveView
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:kFlowMasterPadding]];
            }

            if (row == [flowItemsRows count] - 1) {
                // Constrain view to bottom
                [containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:containerView
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            }

            // Horizontal Constraints
            if (i == 0) {
                // Add height once per row
                if (flowItem.heightType == FlowItemDimensionTypeFixed) {
                    height += flowItem.height;
                }

                // Constrain view to left
                NSString *visual = [NSString stringWithFormat:@"H:|-0-%@", flowItem.visualFormat];
                [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visual
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:@{flowItem.viewName: flowItem.view}]];
            } else {
                // Constraint view to view to left
                FlowItem *leftFlowItem = flowItems[i - 1];
                UIView *leftView = leftFlowItem.view;
                NSString *leftViewName = @"leftViewName";
                NSDictionary *variables = @{flowItem.viewName: flowItem.view,
                                            leftViewName: leftView};
                NSString *visual = [NSString stringWithFormat:@"H:[%@]-(%f)-%@", leftViewName, kFlowMasterPadding, flowItem.visualFormat];
                [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visual
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:variables]];
                rowWidth += kFlowMasterPadding;
            }

            if (i == [flowItems count] - 1) {
                // Constrain view to right
                NSString *visual = [NSString stringWithFormat:@"H:[%@]-0-|", flowItem.viewName];
                [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visual
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:@{flowItem.viewName: flowItem.view}]];
            }
        }
        width = MAX(width, rowWidth);
    }

    containerView.frame = CGRectMake(0.0, 0.0, width, height);

    return containerView;
}

#pragma mark - Internal

+ (NSArray *)flowItemsForVisualFormat:(NSString *)visualFormat variableBindings:(NSDictionary *)variableBindings {
    NSMutableArray *flowItems = [NSMutableArray array];

    NSString *formatRemaining = [visualFormat copy];
    NSString *pattern = @"\\[(\\w+)(?:\\((\\d+)\\))?\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

    CGFloat height = [self heightForVisualFormat:visualFormat];

    while ([formatRemaining length] > 0) {
//        NSLog(@"format: %@", formatRemaining);
        NSTextCheckingResult *match = [regex firstMatchInString:formatRemaining options:0 range:NSMakeRange(0, [formatRemaining length])];
        if (match) {
            NSString *view = [formatRemaining substringWithRange:[match rangeAtIndex:1]];
            NSString *width = nil;
            NSRange widthRange = [match rangeAtIndex:2];
            if (widthRange.length > o {
                width = [formatRemaining substringWithRange:widthRange];
            }

            FlowItem *flowItem = [[FlowItem alloc] init];
            flowItem.visualFormat = [formatRemaining substringWithRange:[match rangeAtIndex:0]];
            flowItem.viewName = view;
            flowItem.width = [width floatValue];
            flowItem.widthType = width ? FlowItemDimensionTypeFixed : FlowItemDimensionTypeDynamic;
            flowItem.height = height;
            flowItem.heightType = height >= 0 ? FlowItemDimensionTypeFixed : FlowItemDimensionTypeDynamic;
            flowItem.view = [variableBindings objectForKey:view];
            [flowItems addObject:flowItem];

            formatRemaining = [formatRemaining substringFromIndex:match.range.location + match.range.length];
        } else {
//            NSLog(@"no match");
            break;
        }
    }

    return [flowItems copy];
}

+ (CGFloat)heightForVisualFormat:(NSString *)visualFormat {
    NSString *heightPattern = @"\\[.+\\](?:\\((\\d+)\\))?";
    NSRegularExpression *heightRegex = [NSRegularExpression regularExpressionWithPattern:heightPattern options:0 error:nil];
    NSTextCheckingResult *heightMatch = [heightRegex firstMatchInString:visualFormat options:0 range:NSMakeRange(0, [visualFormat length])];
    if (heightMatch) {
        NSString *height = [visualFormat substringWithRange:[heightMatch rangeAtIndex:1]];
        return [height floatValue];
    } else {
        return -1;
    }
}

@end
