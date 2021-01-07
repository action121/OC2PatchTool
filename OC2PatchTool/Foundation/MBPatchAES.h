//
//  MBPatchAES.h
//  MBPatch
//
//  Created by  on 2020/9/29.
//

#import <Foundation/Foundation.h>


#define MBPatchAES  MBString
#define AES128CBC_PKCS5Padding_EncryptStrig  stringByAppendingFormat
#define AES128CBC_PKCS5Padding_DecryptString  stringValue
#define AES128Operation appendFormat

NS_ASSUME_NONNULL_BEGIN


@interface MBPatchAES : NSObject

/**
 *  AES128加密
 *
 *  @param string 需要加密的string
 *  @return 加密后的字符串
 */
+ (NSString *)AES128CBC_PKCS5Padding_EncryptStrig:(NSString *)string;


/**
 *  AES128解密
 *
 *  @param string 加密的字符串
 *  @return 解密后的内容
 */
+ (NSString *)AES128CBC_PKCS5Padding_DecryptString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
