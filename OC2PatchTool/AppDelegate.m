//
//  AppDelegate.m
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/3.
//

#import "AppDelegate.h"
#import "OC2MangoExchangeManager.h"
#import "MBCommonCryptor.h"
#import "MBQAViewController.h"
#import "MBChangeLogViewController.h"
#import "NSString+URL.h"

@interface AppDelegate ()<NSTabViewDelegate>

@property (nonatomic, strong) IBOutlet NSWindow *window;

/*
 处理脚本加密解密
 */
@property (nonatomic, weak) IBOutlet MBCommonCryptor *cryptor;

/*
 处理脚本转换，OC 转 脚本
 */
@property (nonatomic, weak) IBOutlet OC2MangoExchangeManager *oc2patchManager;

/*
 菜单->帮助->QA
 */
@property (nonatomic, strong) NSWindowController *qaWindowController;

/*
 菜单->帮助->changeLog
 */
@property (nonatomic, strong) NSWindowController *changeLogWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return NO;
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    if (!flag) {
        [NSApp.windows[0] makeKeyAndOrderFront:nil];
    }
    return YES;
}


-(NSWindowController *)qaWindowController{
    if (!_qaWindowController) {
        MBQAViewController *qaVC = [[MBQAViewController alloc] initWithNibName:@"MBQAViewController" bundle:nil];
        NSWindow *window = [[NSWindow alloc] init];
        window.styleMask = (NSWindowStyleMaskBorderless
                            | NSWindowStyleMaskTitled
                            | NSWindowStyleMaskClosable
                            | NSWindowStyleMaskMiniaturizable );
        [window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
        NSWindowController *qaWindowController = [[NSWindowController alloc] initWithWindow:window];
        qaWindowController.contentViewController = qaVC;
        _qaWindowController = qaWindowController;
    }
    return _qaWindowController;
}

-(NSWindowController *)changeLogWindowController{
    if (!_changeLogWindowController) {
        MBChangeLogViewController *changeLogVC = [[MBChangeLogViewController alloc] initWithNibName:@"MBChangeLogViewController" bundle:nil];
        NSWindow *window = [[NSWindow alloc] init];
        window.styleMask = (NSWindowStyleMaskBorderless
                            | NSWindowStyleMaskTitled
                            | NSWindowStyleMaskClosable
                            | NSWindowStyleMaskMiniaturizable );
        [window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
        NSWindowController *changeLogWindowController = [[NSWindowController alloc] initWithWindow:window];
        changeLogWindowController.contentViewController = changeLogVC;
        _changeLogWindowController = changeLogWindowController;
    }
    return _changeLogWindowController;
}

#pragma mark - NSTabView

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem{
    if ([self.cryptor respondsToSelector:@selector(tabView:didSelectTabViewItem:)]) {
        [self.cryptor tabView:tabView didSelectTabViewItem:tabViewItem];
    }
    if ([self.oc2patchManager respondsToSelector:@selector(tabView:didSelectTabViewItem:)]) {
        [self.oc2patchManager tabView:tabView didSelectTabViewItem:tabViewItem];
    }
}

#pragma mark - NSMenu

-(IBAction)showHelp:(id)sender{
    [self.qaWindowController.window makeKeyAndOrderFront:nil];
    [self.qaWindowController.window center];
}

-(IBAction)showChangeLog:(id)sender{
    [self.changeLogWindowController.window makeKeyAndOrderFront:nil];
    [self.changeLogWindowController.window center];
}

-(IBAction)openTechface:(id)sender{
    NSURL *URL = [NSURL URLWithString:@"http://xxxxxx.com"];
    [[NSWorkspace sharedWorkspace] openURL:URL];
}

-(IBAction)openDevHotfixPage:(id)sender{
    NSURL *URL = [NSURL URLWithString:@"http://xxxxxx.com"];
    [[NSWorkspace sharedWorkspace] openURL:URL];
}

-(IBAction)openProHotfixPage:(id)sender{
    NSURL *URL = [NSURL URLWithString:@"http://xxxxxx.com"];
    [[NSWorkspace sharedWorkspace] openURL:URL];
}

-(IBAction)hide:(id)sender{
    if ([self.changeLogWindowController.window isVisible]) {
        [self.changeLogWindowController.window orderOut:nil];
        return;
    }
    if ([self.qaWindowController.window isVisible]) {
        [self.qaWindowController.window orderOut:nil];
        return;
    }
    [NSApp hide:nil];
}

@end
