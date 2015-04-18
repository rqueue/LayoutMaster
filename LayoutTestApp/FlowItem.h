#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FlowItemDimensionType) {
    FlowItemDimensionTypeFixed,
    FlowItemDimensionTypeDynamic,
    FlowItemDimensionTypeEqual,
};

@interface FlowItem : NSObject

@property (nonatomic, copy) NSString *visualFormat;
@property (nonatomic, copy) NSString *viewName;
@property (nonatomic) UIView *view;
@property (nonatomic) FlowItemDimensionType heightType;
@property (nonatomic) FlowItemDimensionType widthType;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;

@end
