//
//  MBPatchZip.h
//  MBPatch
//
//  Created by  on 2020/9/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface MBPatchZip : NSObject

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
              overwrite:(BOOL)overwrite
                  error:(NSError * *)error;

+ (BOOL)createZipFileAtPath:(NSString *)path withFilesAtPaths:(NSArray<NSString *> *)paths;

@end

NS_ASSUME_NONNULL_END
