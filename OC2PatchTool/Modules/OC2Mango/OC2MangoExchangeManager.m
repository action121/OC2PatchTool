//
//  OC2MangoExchangeManager.m
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/11.
//

#import "OC2MangoExchangeManager.h"
#import "oc2mangoLib.h"
#import "NSTextView+line.h"

@interface OC2MangoExchangeManager ()<NSTextViewDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *objectcTextView;

@property (unsafe_unretained) IBOutlet NSTextView *patchTextView;

@end

@implementation OC2MangoExchangeManager

-(void)awakeFromNib{
    [self.objectcTextView setupLineNumberView];
    [self.patchTextView setupLineNumberView];
}

- (IBAction)changeOC2Patch:(id)sender {
    self.patchTextView.string = @"";
    [self.objectcTextView.lineNumberView  removeAllWarningLines];
    
    NSAttributedString *ocCode = [self insertDefaultCodeIfNeed:self.objectcTextView.attributedString];
    [self.objectcTextView.textStorage setAttributedString:ocCode];
    
    AST *ast = [OCParser parseSource:ocCode.string];
    __block NSString *output = @"";
    if (OCParser.isSuccess) {
        Convert *convert = [[Convert alloc] init];
        [ast.classCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, ORClass* class, BOOL * _Nonnull stop) {
            output = [convert convert:class];
        }];
    }
    if (OCParser.errorAttributedString.length > 0) {
        self.patchTextView.textStorage.attributedString = OCParser.errorAttributedString;
    }else{
        self.patchTextView.string = output.length > 0 ? output : @"出错了";
    }
    
}

-(NSMutableAttributedString *)insertDefaultCodeIfNeed:(NSAttributedString *)ocCode{
    NSMutableAttributedString * result = [[NSMutableAttributedString alloc] initWithAttributedString:ocCode];

    if ([ocCode.string rangeOfString:@"@implementation"].location == NSNotFound) {
        NSMutableAttributedString *classBeginCodeAttributedString = [[NSMutableAttributedString alloc] initWithString:@"@implementation RepalceMe \n\n\n"];
        [self addDefaultAttributeFor:classBeginCodeAttributedString];
        [result insertAttributedString:classBeginCodeAttributedString atIndex:0];
    }
    
    //trim newline
    NSString *trimCode = [ocCode.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange endRange = [trimCode rangeOfString:@"@end" options:NSBackwardsSearch range:NSMakeRange(0, trimCode.length)];
    if (endRange.location == NSNotFound
        || endRange.location + endRange.length < trimCode.length) {
        NSMutableAttributedString *classEndCodeAttributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\n\n@end"];
        [self addDefaultAttributeFor:classEndCodeAttributedString];
        [result appendAttributedString:classEndCodeAttributedString];
    }
    
    return result;
}

-(void)addDefaultAttributeFor:(NSMutableAttributedString *)attributedString{
    [attributedString addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:16] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, attributedString.length)];
}

-(void)scrollRectToVisible:(NSTextView *)textView toLine:(NSInteger)toLine{

    NSLayoutManager *layout = [textView layoutManager];
    NSArray *lines = [[textView string] componentsSeparatedByString:@"\n"];
    NSInteger line = MIN(toLine, lines.count - 1);
    line = MAX(0, line);
    NSUInteger glyphCount = 0;
    for (NSInteger i = 0; i < line; i++){
        NSString *line = [lines objectAtIndex:i];
        glyphCount += [line length];
    }
    NSRange glyphRange = [layout glyphRangeForCharacterRange:NSMakeRange(glyphCount, 0) actualCharacterRange:nil];
    NSRect glyphRect = [layout boundingRectForGlyphRange:glyphRange inTextContainer:[textView textContainer]];
    
    CGFloat pageHeight = textView.enclosingScrollView.bounds.size.height;
    NSInteger pageOfGlyph = ceil(glyphRect.origin.y / pageHeight);
    CGFloat pageStartPoint = pageHeight * (pageOfGlyph - 1);
    NSRect visibleRect = glyphRect;
    CGFloat offsetY = pageStartPoint + pageHeight / 2 - glyphRect.origin.y;
    visibleRect.origin.y -= offsetY;
    visibleRect.origin.y = MIN(visibleRect.origin.y, textView.bounds.size.height);
    visibleRect.origin.y = MAX(visibleRect.origin.y, 0);
    [textView scrollPoint:visibleRect.origin];

    [textView.lineNumberView removeAllWarningLines];
    [textView.lineNumberView setWarningLine:line];
}

#pragma mark - NSTabView

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem{
    if ([tabViewItem.identifier isEqualToString:@"exchange"]) {
        [tabView.window makeFirstResponder:self.objectcTextView];
    }
}

#pragma mark - NSTextView

- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex{
    if (![textView isEqual:self.patchTextView]) {
        return NO;
    }
    if ([link isKindOfClass:[NSURL class]]) {
        NSURL *url = link;
        if ([url.scheme isEqualToString:@"linejump"]) {
            NSInteger line = url.host.integerValue;
            [self scrollRectToVisible:self.objectcTextView toLine:line];
        }
        return YES;
    }
    return NO;
}

@end
