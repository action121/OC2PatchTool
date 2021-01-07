//
//  LineNumberView.h
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/11.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface LineNumberView : NSRulerView

+ (LineNumberView*)rulerView;

@property(nonatomic,weak)id textObj;

@property(nonatomic,strong)NSMutableArray *lineNumberInfo;

@property(nonatomic,strong)NSMutableDictionary *warningLines;

@property(nonatomic,assign)NSUInteger lineCount;

@property(nonatomic,assign)NSUInteger lineNumberOfSelectedLine;

@property(nonatomic,assign)NSUInteger charCount;

// Default: Text Color
@property(nonatomic,strong)NSColor *standardColor;
// Default: Red Color
@property(nonatomic,strong)NSColor *warningColor;

- (void)setMinNumber:(NSUInteger)min maxNumber:(NSUInteger)max;

- (void)setWarningLine:(NSUInteger)index;

- (void)removeWarningLine:(NSUInteger)index;

- (void)removeAllWarningLines;

- (void)adjustYPoint:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
