//
//  SLCodeViewController.m
//  SLCodeObfuscation
//
//  Created by songlin on 2018/8/18.
//  Copyright © 2018年songlin. All rights reserved.
//

#import "SLCodeViewController.h"
#import "SLObfuscationTool.h"
#import "NSFileManager+Extension.h"
#import "NSString+Extension.h"

@interface SLCodeViewController()
@property (weak) IBOutlet NSButton *openBtn;
@property (weak) IBOutlet NSButton *chooseBtn;
@property (weak) IBOutlet NSButton *startBtn;
@property (weak) IBOutlet NSTextField *filepathLabel;
@property (copy) NSString *filepath;
@property (copy) NSString *destFilepath;
@property (weak) IBOutlet NSTextField *destFilepathLabel;
@property (weak) IBOutlet NSTextField *tipLabel;
@property (weak) IBOutlet NSTextField *prefixFiled;
@end

@implementation SLCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipLabel.stringValue = @"";
    self.filepathLabel.stringValue = @"";
    self.destFilepathLabel.stringValue = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefixDidChange) name:NSControlTextDidChangeNotification object:self.prefixFiled];
}

- (void)prefixDidChange {
    NSString *text = [self.prefixFiled.stringValue sl_stringByRemovingSpace];
    self.startBtn.enabled = (text.length != 0) && self.filepath;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)chooseFile:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.prompt = @"选择";
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK) return;
        
        self.filepath = openPanel.URLs.firstObject.path;
        self.filepathLabel.stringValue = [@"需要进行混淆的目录：\n" stringByAppendingString:self.filepath];
        self.destFilepath = nil;
        self.destFilepathLabel.stringValue = @"";
        self.openBtn.enabled = YES;
        [self prefixDidChange];
    }];
}

- (IBAction)openFile:(NSButton *)sender {
    NSString *file = self.destFilepath ? self.destFilepath : self.filepath;
    NSArray *fileURLs = @[[NSURL fileURLWithPath:file]];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

- (IBAction)start:(NSButton *)sender {
    self.destFilepath = nil;
    self.destFilepathLabel.stringValue = @"";
    self.startBtn.enabled = NO;
    self.chooseBtn.enabled = NO;
    self.prefixFiled.enabled = NO;
    
    // 获得前缀
    NSArray *prefixes = [self.prefixFiled.stringValue sl_componentsSeparatedBySpace];
    
    // 处理进度
    void (^progress)(NSString *) = ^(NSString *detail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tipLabel.stringValue = detail;
        });
    };
    
    // 处理结束
    void (^completion)(NSString *) = ^(NSString *fileContent) {
        //拿到内容先存储在本地Mac App路径，该路径还有#define AXXXXX BYYYYY 的形式，
         NSString *path = @"/Users/songlin/CodeConfuseTool/CoderTools/script/input.h";
        

        NSError *error;
        [fileContent writeToFile:path atomically:YES
                                        encoding:NSUTF8StringEncoding error:&error];
           if (error) {
               NSLog(@"存储失败:%@",error.localizedDescription);
               

           }else{
               //然后执行python脚本
                [self invokingPythonScriptAtPath:@"/Users/songlin/CodeConfuseTool/CoderTools/script/nature_language_confuse.py"];
               NSLog(@"成功");
           }
      
       
        
        
        //拷贝文件到相应路径
        self.destFilepath = [self.filepath stringByAppendingPathComponent:@"SLCodeObfuscation.h"];
        self.destFilepath = [NSFileManager sl_checkPathExists:self.destFilepath];
        
         NSFileManager *mgr = [NSFileManager defaultManager];
        
        NSString *outpath = @"/Users/songlin/CodeConfuseTool/CoderTools/script/output.h";
        [mgr copyItemAtPath:outpath toPath:self.destFilepath error:&error];
        //原来的是保存
//        [fileContent writeToFile:self.destFilepath atomically:YES
//                        encoding:NSUTF8StringEncoding error:nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.destFilepathLabel.stringValue = [@"混淆后的文件路径：\n" stringByAppendingString:self.destFilepath];
            
            // 恢复按钮
            self.startBtn.enabled = YES;
            self.chooseBtn.enabled = YES;
            self.prefixFiled.enabled = YES;
        });
    };
    
    // 混淆
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [SLObfuscationTool obfuscateAtDir:self.filepath
                                 prefixes:prefixes
                                 progress:progress
                               completion:completion];
    });
}




-(id) invokingPythonScriptAtPath :(NSString*) pyScriptPath
{
    NSTask *shellTask = [[NSTask alloc]init];
    [shellTask setLaunchPath:@"/bin/bash"];
    NSString *pyStr = [NSString stringWithFormat:@"/Library/Frameworks/Python.framework/Versions/3.7/bin/python3 %@",pyScriptPath];
    [shellTask setArguments:[NSArray arrayWithObjects:@"-c",pyStr, nil]];
    NSPipe *pipe = [[NSPipe alloc]init];
    [shellTask setStandardOutput:pipe];
    [shellTask launch];
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data =[file readDataToEndOfFile];
    NSString *strReturnFromPython = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"The return content from python script is: %@",strReturnFromPython);
    return strReturnFromPython;
}
@end
