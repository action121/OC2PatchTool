//
//  SFDragDestView.m
//  SFIM
//
//  Created by 吴晓明 on 2018/4/25.
//  Copyright © 2018年 . All rights reserved.
//

#import "MBDragDestView.h"


@interface MBDragDestView()

@property(nonatomic,assign)BOOL receivingDrag;

@end


@implementation MBDragDestView

- (instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self){
        [self setUp];
    }
    return self;
}
- (instancetype)init{
    self = [super init];
    if (self){
        [self setUp];
    }
    return self;
}
-(void)awakeFromNib{
    [self setUp];
}

-(void)setUp{

    _dragingTipMessage = @"拖动到这里用来选中脚本zip文件";
    
    self.alphaValue = 0;
    self.wantsLayer = YES;

    self.receivingDrag = NO;
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

-(void)setDragingTipMessage:(NSString *)dragingTipMessage{
    _dragingTipMessage = dragingTipMessage ? : @"";
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect backgroundRect = NSInsetRect(dirtyRect,0,0);
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:backgroundRect];
    [[NSColor colorWithWhite:1 alpha:0.8]  setFill];
    [path fill];
    
    
    {
        NSRect backgroundRect = NSInsetRect(dirtyRect,7,7);
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:backgroundRect];
//        [[NSColor colorWithWhite:1 alpha:0.8]  setFill];
//        [path fill];
        
        if (self.receivingDrag) {
            [[NSColor selectedControlColor] set];
            path.lineWidth = 2;
            path.lineCapStyle = NSRoundLineCapStyle;
            path.lineJoinStyle = NSRoundLineJoinStyle;
            [path stroke];
        }
        
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
        [textStyle setAlignment:NSTextAlignmentCenter];
        [textStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:18],
                                     NSForegroundColorAttributeName: [NSColor darkGrayColor],
                                     NSParagraphStyleAttributeName: textStyle};
        
        
        CGFloat contentWidth = backgroundRect.size.width;
        CGFloat contentHeight = backgroundRect.size.height;
        CGFloat textHeight = 20;
        
        [self.dragingTipMessage drawInRect:NSMakeRect(backgroundRect.origin.x,backgroundRect.origin.y + (contentHeight - textHeight)/2, contentWidth, textHeight) withAttributes:attributes];
    }

}

NSInteger  sfDragCompareViewTags(NSView *firstView, NSView *secondView, void *context);
NSInteger  sfDragCompareViewTags(NSView *firstView, NSView *secondView, void *context){
    NSLog(@"firstView:%@,secondView:%@",firstView,secondView);
    
    if ([firstView isKindOfClass:[MBDragDestView class]]) {
        if (firstView.alphaValue < 1) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }else if ([secondView isKindOfClass:[MBDragDestView class]]) {
        if (secondView.alphaValue < 1) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}

-(void)setReceivingDrag:(BOOL)receivingDrag{
    _receivingDrag = receivingDrag;
    if (!receivingDrag) {
        self.alphaValue = 0;
    }else{
        self.alphaValue = 1;
    }
    [self.superview  sortSubviewsUsingFunction:sfDragCompareViewTags context:nil];
    [self setNeedsDisplay:YES];
}
#pragma mark - Drag

- (BOOL)shouldAllowDragDestination:(id<NSDraggingInfo>)sender {
    
    if (self.dragDestDelegate && [self.dragDestDelegate respondsToSelector:@selector(shouldAllowDragDestination:)]) {
        return  [self.dragDestDelegate shouldAllowDragDestination:sender];
    }
    
    BOOL canAccept = NO;
    NSDictionary *filteringOptions = @{NSPasteboardURLReadingFileURLsOnlyKey:@(YES)};
    NSPasteboard *pasteBoard = sender.draggingPasteboard;
    if ([pasteBoard canReadObjectForClasses:@[[NSURL class]] options:filteringOptions]) {
        canAccept = YES;
    }
    
    return canAccept;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSLog(@"SFDragDestView %s", __FUNCTION__);
    BOOL allow = [self shouldAllowDragDestination:sender];
    self.receivingDrag = allow;
    return self.receivingDrag ? NSDragOperationCopy : NSDragOperationNone;
}

//拖拽进入时调用（多次），用于显示拖拽的小图标
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender{
    if (self.receivingDrag) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"SFDragDestView %s", __FUNCTION__);
    BOOL allow = [self shouldAllowDragDestination:sender];
    return allow;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    NSLog(@"SFDragDestView %s", __FUNCTION__);
    self.receivingDrag = NO;

    if (self.dragDestDelegate && [self.dragDestDelegate respondsToSelector:@selector(mbPerformDragOperation:)]) {
        [self.dragDestDelegate mbPerformDragOperation:sender];
        return YES;
    }
    
    return YES;
}

- (void)draggingExited:(nullable id <NSDraggingInfo>)sender{
    NSLog(@"%s", __FUNCTION__);
    self.receivingDrag = NO;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender{
    self.receivingDrag = NO;
    NSLog(@"%s", __FUNCTION__);
}

- (void)concludeDragOperation:(nullable id <NSDraggingInfo>)sender{
    NSLog(@"%s", __FUNCTION__);
    if (self.dragDestDelegate && [self.dragDestDelegate respondsToSelector:@selector(concludeDragOperation:)]) {
        [self.dragDestDelegate concludeDragOperation:sender];
    }
}

- (BOOL)wantsPeriodicDraggingUpdates{
    NSLog(@"%s", __FUNCTION__);
    if (self.dragDestDelegate && [self.dragDestDelegate respondsToSelector:@selector(wantsPeriodicDraggingUpdates)]) {
        return [self.dragDestDelegate wantsPeriodicDraggingUpdates];
    }
    return NO;
}

- (void)updateDraggingItemsForDrag:(nullable id <NSDraggingInfo>)sender{
    NSLog(@"%s", __FUNCTION__);
    if (self.dragDestDelegate && [self.dragDestDelegate respondsToSelector:@selector(updateDraggingItemsForDrag:)]) {
        [self.dragDestDelegate updateDraggingItemsForDrag:sender];
    }
}
@end
