//
//  LineNumberView.m
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/11.
//

#import "LineNumberView.h"

@interface LineNumberView(){
    NSRange _validRange;
    BOOL _adjY;
}

@end

@implementation LineNumberView

-(void)awakeFromNib{
    
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        _lineNumberInfo = [[NSMutableArray alloc] initWithCapacity:0];
        _validRange = NSMakeRange(0, 0);
        _adjY = NO;
        
        _warningLines = [[NSMutableDictionary alloc] initWithCapacity:0];
        _standardColor = [NSColor textColor];
        _warningColor = [NSColor redColor];
    }
    return self;
}

+ (LineNumberView*)rulerView {
    return [[LineNumberView alloc] init];
}

- (void)dealloc{
    if (_textObj){
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSTextViewDidChangeSelectionNotification
                                                      object:_textObj];
    }
}

#pragma mark -

- (void)_didChange:(NSNotification*)not {
    [self setNeedsDisplay:YES];
}

- (void)_calcPoint{
    NSTextView *textView = (NSTextView*)[[self scrollView] documentView];
    NSLayoutManager *layout = [textView layoutManager];
    NSArray *lines = [[textView string] componentsSeparatedByString:@"\n"];
    
    NSUInteger cursorPoint = [textView selectedRange].location;
    NSString *toCursor = [[textView string] substringWithRange:NSMakeRange(0, cursorPoint)];
    NSArray *linesOfToCursor = [toCursor componentsSeparatedByString:@"\n"];
    
    NSUInteger charCount = [layout numberOfGlyphs];
    NSUInteger i, lineCount = 0, lineCountToCursor = 0;
    NSUInteger glyphCount = 0;
    NSPoint scrollPoint = [[[self scrollView] contentView] bounds].origin;
    
    if (_adjY)
        scrollPoint.y -= 54;
    
    if (lines){
        lineCount = [lines count];
    }
    
    if (linesOfToCursor){
        lineCountToCursor = [linesOfToCursor count];
    }
    
    [_lineNumberInfo removeAllObjects];
    for (i=0; i<lineCount; i++){
        NSString *line = [lines objectAtIndex:i];
        NSRect lineRect = [layout extraLineFragmentUsedRect];
        
        if (i < lineCount-1){
            line = [line stringByAppendingString:@"\n"];
        }
        
        if ([line length] != 0){
            lineRect = [layout lineFragmentUsedRectForGlyphAtIndex:glyphCount
                                                        effectiveRange:NULL];
        }
        
        NSPoint linePoint = NSMakePoint(3,
                                        NSMinY(lineRect) +NSHeight(lineRect)/2.0 -scrollPoint.y);
        
        glyphCount += [line length];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     NSStringFromPoint(linePoint),@"linePoint",nil];
        
        if (i+1 == lineCountToCursor){
            [info setObject:NSStringFromPoint(NSMakePoint(cursorPoint, i)) forKey:@"cursorPoint"];
        }
        [_lineNumberInfo addObject:info];
    }
    
    _lineCount = lineCount;
    _lineNumberOfSelectedLine = lineCountToCursor;
    _charCount = charCount;
}

- (void)setTextObj:(id)textObj{
    if (_textObj){
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSTextViewDidChangeSelectionNotification
                                                      object:_textObj];
    }

    _textObj = textObj;
    
    if (textObj) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_didChange:)
                                                     name:NSTextViewDidChangeSelectionNotification
                                                   object:textObj];
    }
}

- (void)setStandardColor:(NSColor*)color{
    if (color){
        _standardColor = color;
        [self setNeedsDisplay:YES];
    }
}

- (void)setWarningColor:(NSColor*)color{
    if (color){
        _warningColor = color;
        [self setNeedsDisplay:YES];
    }
}

- (void)setMinNumber:(NSUInteger)min maxNumber:(NSUInteger)max {
    _validRange = NSMakeRange(min, max);
}

- (NSString*)_warningKey:(NSUInteger)integer {
    return  [NSString stringWithFormat:@"%lu",(unsigned long)integer];
}

- (void)setWarningLine:(NSUInteger)index{
    if (index != NSNotFound){
        [_warningLines setValue:@(YES) forKey:[self _warningKey:index]];
    };
    [self setNeedsDisplay:YES];
}

- (void)removeWarningLine:(NSUInteger)index{
    if (index != NSNotFound){
        [_warningLines removeObjectForKey:[self _warningKey:index]];
    }
    [self setNeedsDisplay:YES];
}

- (void)removeAllWarningLines {
    [_warningLines removeAllObjects];
    [self setNeedsDisplay:YES];
    
}

- (BOOL)_isWarningLineSet:(NSUInteger)index{
    if ([_warningLines objectForKey:[self _warningKey:index]]){
        return YES;
    }
    return NO;
}

- (void)adjustYPoint:(BOOL)flag {
    _adjY = YES;
    [self setNeedsDisplay:YES];
}

- (void)_drawNumber:(NSUInteger)num
            atPoint:(NSPoint)point
     showCursorMark:(BOOL)markFlag
         validRange:(NSRange)range
          drawnRect:(NSRect)rect{
    NSString *numStr = [NSString stringWithFormat:@"%02lu", (unsigned long)num];
    NSMutableDictionary *att = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSFont *font = [NSFont messageFontOfSize:9];
    NSRect fontRect = [font boundingRectForFont];
    float pxlWidth = NSWidth(fontRect) + NSMinX(fontRect);
    float pxlHeight = NSHeight(fontRect) + NSMinY(fontRect);
    NSPoint numberPoint = NSMakePoint(point.x/* +pxlWidth*/, point.y -pxlHeight/2.0);

    [att setObject:font forKey:NSFontAttributeName];
    if (num >= range.location && num <= range.length){
        [att setObject:_standardColor forKey:NSForegroundColorAttributeName];
    }else if (range.length == 0){
        [att setObject:_standardColor forKey:NSForegroundColorAttributeName];
    }else{
        [att setObject:_warningColor forKey:NSForegroundColorAttributeName];
    }

    if ([self _isWarningLineSet:num]){
        [att setObject:_warningColor forKey:NSForegroundColorAttributeName];
    }
    
    NSRect drawnRect;
    drawnRect.origin = numberPoint;
    drawnRect.size = [numStr sizeWithAttributes:att];
    if (NSIntersectsRect(drawnRect, rect)){
        [numStr drawAtPoint:numberPoint withAttributes:att];
    }
    
    if (markFlag){
        NSString *caretMark = @">";
        
        [caretMark drawAtPoint:NSMakePoint(NSWidth([self bounds]) -pxlWidth +5,
                                           point.y -pxlHeight/2.0) withAttributes:att];
    }
}

- (void)drawRect:(NSRect)rect
{
    NSGraphicsContext *nsctx = [NSGraphicsContext currentContext];
    [nsctx saveGraphicsState];
    
    [[NSColor controlHighlightColor] set];
    [NSBezierPath fillRect:rect];
    
    [nsctx setShouldAntialias:NO];
    [[NSColor controlShadowColor] set];
    
    CGContextRef context = (CGContextRef)[nsctx graphicsPort];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,NSWidth(rect)-1, 0);
    CGContextAddLineToPoint(context,NSWidth(rect)-1,NSHeight([self frame]));
    CGContextStrokePath(context);
    
    [nsctx restoreGraphicsState];
    
    [self _calcPoint];
    
    NSUInteger i, n = [_lineNumberInfo count];
    for (i=0; i<n; i++){
        NSDictionary *info = [_lineNumberInfo objectAtIndex:i];
        NSPoint point = NSPointFromString([info objectForKey:@"linePoint"]);
        
        BOOL cursorFlag = NO;
//        if ([info objectForKey:@"cursorPoint"]){
//            cursorFlag = YES;
//        }
        
        [self _drawNumber:i+1
                  atPoint:point
           showCursorMark:cursorFlag
               validRange:_validRange
                drawnRect:rect];
    }
}

@end
