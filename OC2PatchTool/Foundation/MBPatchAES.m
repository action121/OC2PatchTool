//
//  MBPatchAES.m
//  MBPatch
//
//  Created by  on 2020/9/29.
//

#import "MBPatchAES.h"
#import <CommonCrypto/CommonCryptor.h>


#define XOR_KEY 0xBB

//#error 把kMBPatchAESKEY换成自己的私有密码，换完后删除本行即可。
//例：key ： 0123456789876543
#define kMBPatchAESKEY(v)\
do{\
    unsigned char str[] = {\
        (XOR_KEY ^ '0'),\
        (XOR_KEY ^ '1'),\
        (XOR_KEY ^ '2'),\
        (XOR_KEY ^ '3'),\
        (XOR_KEY ^ '4'),\
        (XOR_KEY ^ '5'),\
        (XOR_KEY ^ '6'),\
        (XOR_KEY ^ '7'),\
        (XOR_KEY ^ '8'),\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '8'),\
        (XOR_KEY ^ '7'),\
        (XOR_KEY ^ '6'),\
        (XOR_KEY ^ '5'),\
        (XOR_KEY ^ '4'),\
        (XOR_KEY ^ '3'),\
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

#define kMBPatchAESIV(v)\
do{\
    unsigned char str[] = {\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '9'),\
        (XOR_KEY ^ '1'),\
        (XOR_KEY ^ '1'),\
        (XOR_KEY ^ '1'),\
        (XOR_KEY ^ '1'),\
        (XOR_KEY ^ '2'),\
        (XOR_KEY ^ '3'),\
        (XOR_KEY ^ '4'),\
        (XOR_KEY ^ '5'),\
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



@implementation MBPatchAES

//加密

+ (NSString *)AES128CBC_PKCS5Padding_EncryptStrig:(NSString *)string{
    NSString *v = nil;
    kMBPatchAESKEY(&v);
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData = [self AES128Operation:kCCEncrypt data:data];
    NSString *encryptring =  [encryptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encryptring;
}


+ (NSString *)AES128CBC_PKCS5Padding_DecryptString:(NSString *)string{

    NSData *decryptBase64data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decryptData = [self AES128Operation:kCCDecrypt data:decryptBase64data];
    NSString *decryptString = [[NSString alloc]initWithData:decryptData encoding:NSUTF8StringEncoding];
    return decryptString;
    
}


+ (NSData *)AES128Operation:(CCOperation)operation data:(NSData *)data {
    NSString *k = nil;
    kMBPatchAESKEY(&k);
    NSString *i = nil;
    kMBPatchAESIV(&i);
    
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [k getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    
    [i getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    }
    free(buffer);
    return nil;
}

@end
