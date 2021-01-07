//
//  NSTextView+line.h
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/11.
//

#import <Cocoa/Cocoa.h>
#import "LineNumberView.h"

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface NSTextView (line)

@property(strong)IBOutlet LineNumberView *lineNumberView;

-(void)setupLineNumberView;

@end

NS_ASSUME_NONNULL_END
