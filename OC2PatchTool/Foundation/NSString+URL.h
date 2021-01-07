//
//  NSString+URL.h
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (URL)

+(NSString *)filePathFromURL:(NSURL *)URL;

/**
 URL encode a string in utf-8.
 @return the encoded string.
 */
- (NSString *)stringByURLEncode;

/**
 URL decode a string in utf-8.
 @return the decoded string.
 */
- (NSString *)stringByURLDecode;

@end

NS_ASSUME_NONNULL_END
