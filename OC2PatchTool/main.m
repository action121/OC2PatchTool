//
//  main.m
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/3.
//

#import <Cocoa/Cocoa.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/syscall.h>   /* For SYS_write etc */
#include <dlfcn.h>

#ifdef DEBUG
#define PTRACE_OPEN 0
#else
#define PTRACE_OPEN 1
#endif

//#define PTRACEOPEN 0

//函数指针，用来保存原始的函数的地址

int main(int argc, const char * argv[]) {
    @autoreleasepool {
#if PTRACE_OPEN
        
        //反注入
        Dl_info info;
        dladdr((void*)ptrace, &info);
        if (strcmp(info.dli_fname, "/usr/lib/system/libsystem_kernel.dylib") != 0) {
            exit(0);
        }
        
        //反调试
        ptrace(PT_DENY_ATTACH, 0, 0, 0);
        
#endif
    }
    return NSApplicationMain(argc, argv);
}
