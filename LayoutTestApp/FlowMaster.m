#import "FlowMaster.h"
#import "NSMutableArray+Stack.h"
#import "FlowRowSpacing.h"
#import "FlowItem.h"

static CGFloat const kFlowMasterVerticalPadding = 10.0;
static CGFloat const kFlowMasterHorizontalPadding = 10.0;
static NSString * const kFlowMasterEqualWidthSyntax = @"==";

@implementation FlowMaster

+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats rowSpacingVisualFormat:(NSString *)rowSpacingVisualFormat variableBindings:(NSDictionary *)variableBindings {
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;

    NSMutableArray *flowItemsRows = [NSMutableArray array];
    for (NSString *visualFormat in visualFormats) {
        NSArray *flowItems = [self flowItemsForVisualFormat:visualFormat variableBindings:variableBindings];
        [flowItemsRows addObject:flowItems];
    }

    CGFloat height = 0;
    CGFloat width = 0;

    NSMutableArray *flowRowSpacings = [NSMutableArray arrayWithArray:[self flowRowSpacingsForRowVisualFormat:rowSpacingVisualFormat]];
    FlowRowSpacing *flowRowSpacing = [flowRowSpacings pop];
    for (NSUInteger row = 0; row < [flowItemsRows count]; row++) {
        if (row > 0) {
            height += kFlowMasterVerticalPadding;
        }

        CGFloat rowWidth = 0;
        NSArray *flowItems = flowItemsRows[row];
        NSMutableArray *flowItemsWithEqualWidths = [NSMutableArray array];
        for (NSUInteger i = 0; i < [flowItems count]; i++) {
            FlowItem *flowItem = flowItems[i];

            switch (flowItem.widthType) {
                case FlowItemDimensionTypeFixed:
                    rowWidth += flowItem.width;
                    break;
                case FlowItemDimensionTypeEqual:
                    [flowItemsWithEqualWidths addObject:flowItem];
                    break;
                default:
                    break;
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
                if (i == 0) {
                    CGFloat constant = 0.0;
                    if (flowRowSpacing && !flowRowSpacing.topRowLabel && [flowRowSpacing.bottomRowLabel isEqualToString:flowItem.rowLabel]) {
                        constant = flowRowSpacing.spacing;
                        flowRowSpacing = [flowRowSpacings pop];
                    }
                    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:containerView
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0
                                                                               constant:constant]];
                } else {
                    FlowItem *firstFlowItem = flowItems[0];
                    UIView *firstView = firstFlowItem.view;
                    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:firstView
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0
                                                                               constant:0.0]];
                }
            } else {
                // Constrain view to a view above
                FlowItem *aboveFlowItem = flowItemsRows[row - 1][0];
                UIView *aboveView = aboveFlowItem.view;

                CGFloat constant = kFlowMasterVerticalPadding;
                if (flowRowSpacing && [flowRowSpacing.topRowLabel isEqualToString:aboveFlowItem.rowLabel] && [flowRowSpacing.bottomRowLabel isEqualToString:flowItem.rowLabel]) {
                    constant = flowRowSpacing.spacing;
                    flowRowSpacing = [flowRowSpacings pop];
                }
                [containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:aboveView
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:constant]];
            }

            if (row == [flowItemsRows count] - 1) {
                // Constrain view to bottom
                if (i == 0) {
                    CGFloat constant = 0.0;
                    if (flowRowSpacing && [flowRowSpacing.topRowLabel isEqualToString:flowItem.rowLabel] && !flowRowSpacing.bottomRowLabel) {
                        constant = flowRowSpacing.spacing;
                        flowRowSpacing = [flowRowSpacings pop];
                    }
                    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:view
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:constant]];
                } else {
                    FlowItem *firstFlowItem = flowItems[0];
                    UIView *firstView = firstFlowItem.view;
                    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:firstView
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:0.0]];
                }
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
                NSString *visual = [NSString stringWithFormat:@"H:[%@]-(%f)-%@", leftViewName, kFlowMasterHorizontalPadding, flowItem.visualFormat];
                [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visual
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:variables]];
                rowWidth += kFlowMasterHorizontalPadding;
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

        if ([flowItemsWithEqualWidths count] > 1) {
            for (NSUInteger k = 1; k < [flowItemsWithEqualWidths count]; k++) {
                FlowItem *previousFlowItem = flowItemsWithEqualWidths[k - 1];
                FlowItem *currentFlowItem = flowItemsWithEqualWidths[k];
                [containerView addConstraint:[NSLayoutConstraint constraintWithItem:previousFlowItem.view
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:currentFlowItem.view
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            }
        }
    }

    containerView.frame = CGRectMake(0.0, 0.0, width, height);

    return containerView;
}

#pragma mark - Internal

+ (NSArray *)flowItemsForVisualFormat:(NSString *)visualFormat variableBindings:(NSDictionary *)variableBindings {
    NSMutableArray *flowItems = [NSMutableArray array];
    NSString *rowLabel = [self rowLabelForVisualFormat:visualFormat];

    NSString *formatRemaining = [self visualFormatByRemovingRowLabel:visualFormat];
    NSString *pattern = @"\\[(\\w+)(\\(([\\d=]+)\\))?\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

    NSString *heightString = [self heightStringForVisualFormat:visualFormat];

    while ([formatRemaining length] > 0) {
        NSTextCheckingResult *match = [regex firstMatchInString:formatRemaining options:0 range:NSMakeRange(0, [formatRemaining length])];
        if (match) {
            NSString *viewString = [formatRemaining substringWithRange:[match rangeAtIndex:1]];
            NSString *widthString = nil;
            NSRange widthRange = [match rangeAtIndex:2];
            if (widthRange.length > 0) {
                widthString = [formatRemaining substringWithRange:[match rangeAtIndex:3]];
            }
            FlowItem *flowItem = [[FlowItem alloc] init];
            flowItem.rowLabel = rowLabel;
            flowItem.visualFormat = [self visualFormatForVisualFormat:[formatRemaining substringWithRange:[match rangeAtIndex:0]] widthString:widthString range:widthRange];
            flowItem.viewName = viewString;
            flowItem.width = [widthString floatValue];
            flowItem.widthType = [self flowItemDimensionTypeForWidthString:widthString];
            flowItem.height = [heightString floatValue];
            flowItem.heightType = heightString ? FlowItemDimensionTypeFixed : FlowItemDimensionTypeDynamic;
            flowItem.view = [variableBindings objectForKey:viewString];
            [flowItems addObject:flowItem];
            formatRemaining = [formatRemaining substringFromIndex:match.range.location + match.range.length];
        } else {
            break;
        }
    }

    return [flowItems copy];
}

+ (FlowItemDimensionType)flowItemDimensionTypeForWidthString:(NSString *)widthString {
    if (!widthString) {
        return FlowItemDimensionTypeDynamic;
    } else if ([widthString isEqualToString:kFlowMasterEqualWidthSyntax]) {
        return FlowItemDimensionTypeEqual;
    } else {
        return FlowItemDimensionTypeFixed;
    }
}

+ (NSString *)visualFormatForVisualFormat:(NSString *)visualFormat widthString:(NSString *)widthString range:(NSRange)range {
    if ([widthString isEqualToString:kFlowMasterEqualWidthSyntax]) {
        NSMutableString *modifiedVisualFormat = [[NSMutableString alloc] init];
        [modifiedVisualFormat appendString:[visualFormat substringToIndex:range.location]];
        NSUInteger widthStringEndIndex = range.location + range.length;
        [modifiedVisualFormat appendString:[visualFormat substringWithRange:NSMakeRange(widthStringEndIndex, [visualFormat length] - widthStringEndIndex)]];
        return [modifiedVisualFormat copy];
    } else {
        return visualFormat;
    }
}

+ (NSString *)heightStringForVisualFormat:(NSString *)visualFormat {
    NSString *heightPattern = @"\\[.+\\](?:\\((\\d+)\\))?";
    NSRegularExpression *heightRegex = [NSRegularExpression regularExpressionWithPattern:heightPattern options:0 error:nil];
    NSTextCheckingResult *heightMatch = [heightRegex firstMatchInString:visualFormat options:0 range:NSMakeRange(0, [visualFormat length])];
    if (heightMatch) {
        NSRange heightValueRange = [heightMatch rangeAtIndex:1];
        if (heightValueRange.length > 0) {
            return [visualFormat substringWithRange:[heightMatch rangeAtIndex:1]];
        }
    }
    return nil;
}

+ (NSString *)rowLabelForVisualFormat:(NSString *)visualFormat {
    NSTextCheckingResult *match = [self rowLabelMatchForVisualFormat:visualFormat];
    if (match) {
        NSRange rowLabelRange = [match rangeAtIndex:1];
        if (rowLabelRange.length > 0) {
            return [visualFormat substringWithRange:rowLabelRange];
        }
    }
    return nil;
}

+ (NSString *)visualFormatByRemovingRowLabel:(NSString *)visualFormat {
    NSTextCheckingResult *match = [self rowLabelMatchForVisualFormat:visualFormat];
    if (match) {
        NSRange range = [match rangeAtIndex:0];
        return [visualFormat substringFromIndex:range.location + range.length];
    }
    return visualFormat;
}

+ (NSTextCheckingResult *)rowLabelMatchForVisualFormat:(NSString *)visualFormat {
    NSString *pattern = @"^(\\w+):";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:visualFormat options:0 range:NSMakeRange(0, [visualFormat length])];
    return match;
}

+ (NSArray *)flowRowSpacingsForRowVisualFormat:(NSString *)rowVisualFormat {
    NSMutableArray *flowRowSpacings = [NSMutableArray array];
    NSString *pattern = @"(?:\\||(?:\\[(\\w+)\\]))-(?:(?:(\\d+))|(?:\\((\\d+)\\)))-(?:\\||(?:\\[(\\w+)\\]))";
    NSString *formatRemaining = [rowVisualFormat copy];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];

    while ([formatRemaining length] > 0) {
        NSTextCheckingResult *match = [regex firstMatchInString:formatRemaining options:0 range:NSMakeRange(0, [formatRemaining length])];
        if (match) {
            NSRange topRowLabelRange = [match rangeAtIndex:1];
            NSRange spacingStringRangeWithoutParen = [match rangeAtIndex:2];
            NSRange spacingStringRangeWithParen = [match rangeAtIndex:3];
            NSRange spacingStringRange = spacingStringRangeWithoutParen.length > 0 ? spacingStringRangeWithoutParen : spacingStringRangeWithParen;
            NSRange bottomRowLabelRange = [match rangeAtIndex:4];

            NSString *topRowLabel = topRowLabelRange.length > 0 ? [formatRemaining substringWithRange:topRowLabelRange] : nil;
            NSString *spacingString = [formatRemaining substringWithRange:spacingStringRange];
            NSString *bottomRowLabel = bottomRowLabelRange.length > 0 ? [formatRemaining substringWithRange:bottomRowLabelRange] : nil;

            FlowRowSpacing *flowRowSpacing = [[FlowRowSpacing alloc] init];
            flowRowSpacing.topRowLabel = topRowLabel;
            flowRowSpacing.bottomRowLabel = bottomRowLabel;
            flowRowSpacing.spacing = [spacingString floatValue];
            [flowRowSpacings addObject:flowRowSpacing];

            if (bottomRowLabelRange.length > 0) {
                formatRemaining = [formatRemaining substringFromIndex:bottomRowLabelRange.location - 1];
            } else {
                break;
            }
        } else {
            break;
        }
    }

    return [flowRowSpacings copy];
}

@end
