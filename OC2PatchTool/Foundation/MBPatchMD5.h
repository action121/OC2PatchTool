//
//  MBPatchMD5.h
//  MBPatch
//
//  Created by  on 2020/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBPatchMD5 : NSObject

+ (NSString *)md5WithFilePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
