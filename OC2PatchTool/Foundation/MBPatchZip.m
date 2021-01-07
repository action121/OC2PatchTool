//
//  MBPatchZip.m
//  MBPatch
//
//  Created by  on 2020/9/30.
//

#import "MBPatchZip.h"
#import <SSZipArchive/SSZipArchive.h>

#define XOR_KEY 0xBB
//#error 把kMBPatchZipPassword换成自己的私有密码，换完后删除本行即可。
//例：key ： helloworld!
#define kMBPatchZipPassword(v)\
do{\
    unsigned char str[] = {\
        (XOR_KEY ^ 'h'),\
        (XOR_KEY ^ 'e'),\
        (XOR_KEY ^ 'l'),\
        (XOR_KEY ^ 'l'),\
        (XOR_KEY ^ 'o'),\
        (XOR_KEY ^ 'w'),\
        (XOR_KEY ^ 'o'),\
        (XOR_KEY ^ 'r'),\
        (XOR_KEY ^ 'l'),\
        (XOR_KEY ^ 'd'),\
        (XOR_KEY ^ '!'),\
        (XOR_KEY ^ '\0')\
    };\
    unsigned char *p = str;\
    while( ((*p) ^= XOR_KEY) != '\0') {\
        p++;\
    }\
    static unsigned char result[sizeof(str)];\
    memcpy(result, str, sizeof(str));\
    *v = [NSString stringWithFormat:@"%s",result];\
}\
while(0);\

@implementation MBPatchZip

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
              overwrite:(BOOL)overwrite
                  error:(NSError * *)error {
    NSString *v = nil;
    kMBPatchZipPassword(&v);
    return [SSZipArchive unzipFileAtPath:path toDestination:destination overwrite:overwrite password:v error:error delegate:nil];
}

+ (BOOL)createZipFileAtPath:(NSString *)path withFilesAtPaths:(NSArray<NSString *> *)paths{
    NSString *v = nil;
    kMBPatchZipPassword(&v);
    return [SSZipArchive createZipFileAtPath:path withFilesAtPaths:paths withPassword:v];
}

@end
