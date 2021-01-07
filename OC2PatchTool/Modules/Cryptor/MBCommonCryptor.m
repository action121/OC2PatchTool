//
//  MBCommonCryptor.m
//  MBCommonCryptor
//
//  Created by 吴晓明 on 2020/12/3.
//

#import "MBCommonCryptor.h"
#import "MBPatchAES.h"
#import "MBPatchZip.h"
#import "NSString+URL.h"
#import "NSTextView+line.h"
#import "MBDragDestView.h"
#import <Masonry.h>


@interface MBCommonCryptor()<NSPathControlDelegate,MBDraggingDestination>

/*解密相关*/
@property (unsafe_unretained) IBOutlet NSTextView *inputForDecryptTextView;
@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSTextField *tipLabel;


/*加密相关*/
@property (unsafe_unretained) IBOutlet NSTextView *inputForExportTextView;
@property (weak) IBOutlet NSTextField *exportFileNameTextField;

//用来支持拖拽
@property (nonatomic,strong) MBDragDestView *dragDestView;

@end

@implementation MBCommonCryptor

-(void)awakeFromNib{
    [self.inputForDecryptTextView setupLineNumberView];
    [self.inputForExportTextView setupLineNumberView];
    [self.pathControl.superview addSubview:self.dragDestView positioned:NSWindowBelow relativeTo:self.pathControl.superview.subviews.firstObject];
    [self.dragDestView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
}

-(MBDragDestView *)dragDestView{
    if (!_dragDestView) {
        _dragDestView = [[MBDragDestView alloc] initWithFrame:CGRectZero];
        _dragDestView.dragDestDelegate = self;
    }
    return _dragDestView;
}

-(NSString *)cacheRootDir{
    NSString *cacheRootDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return cacheRootDir;
}

-(NSString *)tempCodeDir{
    NSString *cacheRootDir = [self cacheRootDir];
    NSString *tempCodeDir = [cacheRootDir stringByAppendingString:@"/MBPatchFiles/exportTemp"];
    return tempCodeDir ;
}

-(void)clearTempDir{
    NSString *cacheRootDir = [self cacheRootDir];
    NSString *tempDir = [cacheRootDir stringByAppendingString:@"/MBPatchFiles"];
    [[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
}

#pragma mark - 解密

- (IBAction)decrypt:(id)sender {
    NSString *inputText = self.inputForDecryptTextView.string;
    NSString *decryptContent = [MBPatchAES AES128CBC_PKCS5Padding_DecryptString:inputText];
    self.inputForDecryptTextView.string = decryptContent.length > 0 ? decryptContent : @"解密失败";
}

- (IBAction)decryptFromFile:(id)sender {
   
    NSPathControlItem *item = self.pathControl.pathItems.lastObject;
    NSString *zipFilePath =  [NSString filePathFromURL:item.URL];
    BOOL isFolder = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:zipFilePath isDirectory:&isFolder]
        || isFolder) {
        self.inputForDecryptTextView.string = @"请选择文件";
        return;
    }
    
    NSString *cacheRootDir = [self cacheRootDir];
    NSString *unzipFileDirPath = [cacheRootDir stringByAppendingPathComponent:[NSString stringWithFormat:@"MBPatchFiles/%@/",zipFilePath.lastPathComponent.stringByDeletingPathExtension]];
    [[NSFileManager defaultManager] removeItemAtPath:unzipFileDirPath error:nil];
    NSError *error = nil;
    [MBPatchZip unzipFileAtPath:zipFilePath toDestination:unzipFileDirPath overwrite:YES error:&error];
    if (error) {
        self.inputForDecryptTextView.string = error.description ? : @"zip文件解压失败";
        [self clearTempDir];
        return;
    }
    
    NSArray *unzipFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzipFileDirPath error:nil];
    NSString *codeFilePath = nil;
    for (NSString *filePath in unzipFiles) {
        if ([filePath.pathExtension isEqualToString:@"code"]) {
            codeFilePath = [unzipFileDirPath stringByAppendingFormat:@"/%@",unzipFiles.firstObject];
            break;
        }
    }
    if (!codeFilePath) {
        self.inputForDecryptTextView.string = @"zip文件解压后没有找到加密文件";
        [self clearTempDir];
        return;
    }
    
    NSString *inputText = [[NSString alloc] initWithContentsOfFile:codeFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *decryptContent = [MBPatchAES AES128CBC_PKCS5Padding_DecryptString:inputText];
    
    self.inputForDecryptTextView.string = decryptContent.length > 0 ? decryptContent : @"解密失败";
    [self clearTempDir];
}

#pragma mark - 加密

- (IBAction)export:(id)sender {
    if (self.exportFileNameTextField.stringValue.length == 0) {
        self.inputForExportTextView.string = @"请输入文件名";
        return;
    }
    if (self.inputForExportTextView.string.length == 0) {
        self.inputForExportTextView.string = @"请输入内容";
        return;
    }
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"zip"];
    savePanel.nameFieldStringValue = self.exportFileNameTextField.stringValue;
    [savePanel beginSheetModalForWindow:self.inputForExportTextView.window completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK) {
            return;
        }
        [self saveReleasedFile:savePanel.URL];
    }];

}

-(void)saveReleasedFile:(NSURL *)saveFileURL{
    NSString *saveFilePath = [NSString filePathFromURL:saveFileURL];
    if (!saveFilePath) {
        return;
    }

    NSString *inputText = self.inputForExportTextView.string;
    NSString *encryptContent = [MBPatchAES AES128CBC_PKCS5Padding_EncryptStrig:inputText];
    if (encryptContent.length == 0) {
        self.inputForExportTextView.string = @"加密失败";
        return;
    }
    
    NSString *codeFileName = self.exportFileNameTextField.stringValue;
    NSString *tempCodeDir = [self tempCodeDir];
    [self clearTempDir];
    [[NSFileManager defaultManager] createDirectoryAtPath:tempCodeDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *codeFilePath = [tempCodeDir stringByAppendingFormat:@"/%@.code",codeFileName];
    [encryptContent writeToFile:codeFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    BOOL success = [MBPatchZip createZipFileAtPath:saveFilePath withFilesAtPaths:@[codeFilePath]];
    if (success
        && [[NSFileManager defaultManager] fileExistsAtPath:saveFilePath]) {
        self.inputForExportTextView.string = [NSString stringWithFormat:@"导出成功，文件保存在：\n%@",saveFilePath];
        [[NSWorkspace sharedWorkspace] selectFile:saveFilePath inFileViewerRootedAtPath:@""];
    }else{
        self.inputForExportTextView.string = @"导出失败";
    }
    [self clearTempDir];
}

#pragma mark - NSTabView

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem{
    if ([tabViewItem.identifier isEqualToString:@"encrypt"]) {
        [tabView.window makeFirstResponder:self.inputForExportTextView];
    }
}

- (BOOL)shouldAllowDragDestination:(id<NSDraggingInfo>)sender{
    BOOL canAccept = NO;
    NSDictionary *filteringOptions = @{NSPasteboardURLReadingFileURLsOnlyKey:@(YES)};
    NSPasteboard *pasteBoard = sender.draggingPasteboard;
    if ([pasteBoard canReadObjectForClasses:@[[NSURL class]] options:filteringOptions]) {
        canAccept = YES;
    }
    
    return canAccept;
}

-(void)mbPerformDragOperation:(id <NSDraggingInfo>)sender{
    [self.pathControl performDragOperation:sender];
}

@end
