//
//  NSTextView+line.m
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/11.
//

#import "NSTextView+line.h"
#import "LineNumberView.h"
#import <objc/runtime.h>

@implementation NSTextView (line)

char *LineNumberViewAssocObjKey = "lineNumberView";

-(void)setLineNumberView:(LineNumberView *)lineView{
    objc_setAssociatedObject(self, &LineNumberViewAssocObjKey, lineView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(LineNumberView *)lineNumberView{
    return objc_getAssociatedObject(self,&LineNumberViewAssocObjKey);
}

-(void)setupLineNumberView{
    if (!self.font){
        self.font = [NSFont systemFontOfSize:16];
    }
    
    LineNumberView *lineNumberView = [[LineNumberView alloc] init];
    lineNumberView.textObj = self;
    [self setLineNumberView:lineNumberView];
    
    self.enclosingScrollView.verticalRulerView = lineNumberView;
    self.enclosingScrollView.hasVerticalRuler = YES;
    self.enclosingScrollView.rulersVisible = YES;
    self.postsBoundsChangedNotifications = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(framDidChange:) name:NSViewFrameDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:self];

}

-(void)framDidChange:(NSNotification*)notification {
    self.lineNumberView.needsDisplay = YES;
}
   
-(void)textDidChange:(NSNotification*)notification {
    self.lineNumberView.needsDisplay = YES;
}

@end
