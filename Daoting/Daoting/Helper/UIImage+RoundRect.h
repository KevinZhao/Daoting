#import <UIKit/UIKit.h>
//#import "SQLibs.h"
 
enum {
    UIImageRoundedCornerTopLeft = 1,
    UIImageRoundedCornerTopRight = 1 << 1,
    UIImageRoundedCornerBottomRight = 1 << 2,
    UIImageRoundedCornerBottomLeft = 1 << 3
}
typedef UIImageRoundedCorner;
 
@interface UIImage (RoundRect)
 
- (UIImage *)roundedRectWith:(float)radius;
- (UIImage *)roundedRectWith:(float)radius cornerMask:(UIImageRoundedCorner)cornerMask;
 
@end