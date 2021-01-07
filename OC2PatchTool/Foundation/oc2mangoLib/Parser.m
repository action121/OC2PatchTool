//
//  Parser.m
//  oc2mangoLib
//
//  Created by Jiang on 2019/4/24.
//  Copyright © 2019年 SilverFruity. All rights reserved.
//

#import "Parser.h"
#import "RunnerClasses.h"
#import <APPKit/AppKit.h>

@implementation CodeSource
- (instancetype)initWithFilePath:(NSString *)filePath{
    self = [super init];
    self.filePath = filePath;
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    self.source = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return self;
}
- (instancetype)initWithSource:(NSString *)source{
    self = [super init];
    self.source = source;
    return self;
}
@end
@implementation Parser

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    static Parser * _instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [Parser new];
    });
    return _instance;
}
- (BOOL)isSuccess{
    return self.source && self.error == nil;
}
- (AST *)parseCodeSource:(CodeSource *)source{
    [self clear];
    if (source.source == nil) {
        return nil;
    }
    GlobalAst = [AST new];
    extern void yy_set_source_string(char const *source);
    extern void yyrestart (FILE * input_file );
    extern int yyparse(void);
    self.source = source;
    yy_set_source_string([source.source UTF8String]);
    if (yyparse()) {
        yyrestart(NULL);
        NSLog(@"\n----Error: \n  PATH: %@\n  INFO:%@",self.source.filePath,self.error);
    }

    return GlobalAst;
}
- (AST *)parseSource:(NSString *)source{
    return [self parseCodeSource:[[CodeSource alloc] initWithSource:source]];
}

-(void)clear{
    self.errorAttributedString = nil;
    self.error = nil;
    self.source = nil;
}

-(void)onParserError:(const char *)error{
    extern unsigned long yylineno , yycolumn , yylen;
    extern char linebuf[500];
    extern char *yytext;
    NSString *text = [NSString stringWithUTF8String:yytext];
    NSString *line = [NSString stringWithUTF8String:linebuf];
    NSRange range = [line rangeOfString:text];
    NSMutableString *str = [NSMutableString string];
    if(range.location != NSNotFound){
        for (int i = 0; i < range.location; i++){
            [str appendString:@" "];
        }
        for (int i = 0; i < range.length; i++){
            [str appendString:@"^"];
        }
    }else{
        str = [text mutableCopy];
    }
    NSInteger toLine = yylineno;
    NSString *lineInfo = [NSString stringWithFormat:@"Line: %@",@(toLine)];
    NSString *errorInfo = [NSString stringWithFormat:@"出错了:\n\n%@\n%@\n%@\n %s\n-------------------\n",lineInfo,line,str,error];
    self.error = errorInfo;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:errorInfo];
    [attributedString addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[NSString stringWithFormat:@"linejump://%@",@(toLine)]] range:[errorInfo rangeOfString:lineInfo]];
    self.errorAttributedString = attributedString;
}

@end
