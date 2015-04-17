#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FlowMaster : NSObject

// Returns view at min size
+ (UIView *)viewFromVisualFormats:(NSArray *)visualFormats variableBindings:(NSDictionary *)variableBindings;

@end
