//
//  MBTextView.m
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/14.
//

#import "MBTextView.h"

@implementation MBTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)awakeFromNib{
    
}

-(void)setAllowDragging:(BOOL)allowDragging{
    _allowDragging = allowDragging;
}

- (NSArray *)acceptableDragTypes{
    if (_allowDragging) {
        return [super acceptableDragTypes];
    }
    return nil;
}

- (void)noDragInView:(NSView *)view{
    [view unregisterDraggedTypes];
    for (NSView *subview in view.subviews){
        if (subview.subviews.count){
            [self noDragInView:subview];
        }else{
            [subview unregisterDraggedTypes];
        }
    }
}

@end
