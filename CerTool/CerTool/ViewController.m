//
//  ViewController.m
    

#import "ViewController.h"
#import <Cocoa/Cocoa.h>

@interface ViewController()
@property (nonatomic,copy) NSString *selectCSRPath;
@property (weak) IBOutlet NSButton *selectCERPathBtn;
@property (nonatomic,copy) NSString *cerPath;
@property (weak) IBOutlet NSButton *selectPemPathBtn;
@property (nonatomic,copy) NSString *pemPath;
@property (nonatomic,copy) NSString *selectP12Path;
@property (weak) IBOutlet NSTextField *p12PwdTextField;
@end

@implementation ViewController

- (IBAction)helpAction:(NSButton *)sender {
    NSString *helpStr = @"创建CSR文件会生成CSR和PEM文件,利用CSR文件去苹果后台请求cer,在导出p12时,pem需和生成CSR文件所产生的pem一致";
    [self showErrorString:helpStr];
}
- (IBAction)selectCSRPathAction:(NSButton *)sender {
    [self getOutPathWithHandler:^(BOOL isSuccess, NSURL *path) {
        if (isSuccess && path.path) {
            [sender setTitle:path.path];
            self.selectCSRPath = path.path;
            NSLog(@"%@",self.selectCSRPath);
        }
    }];
}
- (IBAction)createCSRAction:(NSButton *)sender {
    if (!self.selectCSRPath || !self.selectCSRPath.length) {
        [self showErrorString:@"请选择CSR导出路径"];
        return;
    }
    NSString *filePath = self.selectCSRPath;
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *csrFileName = @"CertificateSigningRequest.certSigningRequest";
    NSString *pemFileName = @"myKey.pem";
    NSString *csrPath = [NSString stringWithFormat:@"%@/%@",self.selectCSRPath,csrFileName];
    NSString *pemPath = [NSString stringWithFormat:@"%@/%@",self.selectCSRPath,pemFileName];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CreateCSR" ofType:@".py"];
    NSString *pyCode = [NSString stringWithFormat:@"python %@ -c %@ -p %@",path,csrPath,pemPath];
    NSTask *task = [NSTask new];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-c",pyCode];
    NSPipe *pipe = [[NSPipe alloc]init];
//    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [task launch];
//    NSError *error;
//    [task launchAndReturnError:&error];
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data =[file readDataToEndOfFile];
    NSString *strReturnFromPython = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"The return content from python script is: %@",strReturnFromPython);
//    char *code = [pyCode UTF8String];
//    system(code);
    NSLog(@"脚本运行完成");
    if ([[NSFileManager defaultManager] fileExistsAtPath:csrPath] && [[NSFileManager defaultManager] fileExistsAtPath:pemPath]) {
        self.pemPath = pemPath;
        [self.selectPemPathBtn setTitle:pemPath];
    }else{
        if (strReturnFromPython && strReturnFromPython.length) {
            [self showErrorString:strReturnFromPython];
        }
    }
}
- (IBAction)selectCERAction:(NSButton *)sender {
    [self getFilePathWithFileTypes:@[@"cer"] handler:^(BOOL isSuccess,NSURL *path) {
        if (isSuccess && path.path) {
            self.cerPath = path.path;
            [sender setTitle:path.path];
        }
    }];
}
- (IBAction)selectPEMAction:(NSButton *)sender {
    [self getFilePathWithFileTypes:@[@"pem"] handler:^(BOOL isSuccess,NSURL *path) {
        if (isSuccess && path.path) {
            [sender setTitle:path.path];
            self.pemPath = path.path;
        }
    }];
}
- (IBAction)selectP12PathAction:(NSButton *)sender {
    [self getOutPathWithHandler:^(BOOL isSuccess, NSURL *path) {
        if (isSuccess && path.path) {
            [sender setTitle:path.path];
            self.selectP12Path = path.path;
        }
    }];
}
- (IBAction)outputP12Action:(NSButton *)sender {
    if (!self.cerPath) {
        [self showErrorString:@"请选择Cer文件路径"];
        return;
    }
    if (!self.pemPath) {
        [self showErrorString:@"请选择PEM文件路径"];
        return;
    }
    if (!self.selectP12Path) {
        [self showErrorString:@"请选择P12文件导出路径"];
        return;
    }
    if (!self.p12PwdTextField.stringValue || !self.p12PwdTextField.stringValue.length) {
        [self showErrorString:@"请输入P12密码"];
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.cerPath]) {
        [self showErrorString:@"Cer文件不存在"];
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.pemPath]) {
        [self showErrorString:@"PEM文件不存在"];
        return;
    }
    NSString *cerFileName = [self.cerPath componentsSeparatedByString:@"/"].lastObject;
    cerFileName = [cerFileName componentsSeparatedByString:@"."].firstObject;
    NSString *p12Name = [NSString stringWithFormat:@"%@.p12",cerFileName];
    NSString *p12Path = [NSString stringWithFormat:@"%@/%@",self.selectP12Path,p12Name];
    NSString *p12Pwd = self.p12PwdTextField.stringValue;
    //开始导出P12
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CreateP12" ofType:@".py"];
    NSString *pyCode = [NSString stringWithFormat:@"python %@ -c %@ -p %@ -d %@ -w %@",path,self.cerPath,self.pemPath,p12Path,p12Pwd];
    NSTask *task = [NSTask new];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-c",pyCode];
    NSPipe *pipe = [[NSPipe alloc]init];
//    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [task launch];
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data =[file readDataToEndOfFile];
    NSString *strReturnFromPython = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"脚本运行完成");
    if ([[NSFileManager defaultManager] fileExistsAtPath:p12Path]) {
        [self showErrorString:@"导出p12文件成功"];
    }else{
        if (strReturnFromPython && strReturnFromPython.length) {
            [self showErrorString:strReturnFromPython];
        }
    }
}
- (void)getOutPathWithHandler:(void(^)(BOOL isSuccess,NSURL *path))handler{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    //是否能够创建文件夹
    panel.canCreateDirectories = YES;
    //设置是否解析别名
    panel.resolvesAliases = NO;
    //设置是否允许选择文件夹
    panel.canChooseDirectories = YES;
    //设置是否允许选择文件
    panel.canChooseFiles = NO;
    //设置是否允许多选
    panel.allowsMultipleSelection = NO;
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton && panel.URLs.count) {
        if (handler) {
            handler(YES,panel.URLs.firstObject);
        }
    }else{
        if (handler) {
            handler(NO,nil);
        }
    }
}
- (void)getFilePathWithFileTypes:(NSArray *)fileTypes handler:(void(^)(BOOL isSuccess,NSURL *path))handler{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    if (fileTypes && fileTypes.count) {
        panel.allowedFileTypes = fileTypes;
    }
    //设置是否解析别名
    panel.resolvesAliases = YES;
    //设置是否允许选择文件夹
    panel.canChooseDirectories = NO;
    //设置是否允许选择文件
    panel.canChooseFiles = YES;
    //设置是否允许多选
    panel.allowsMultipleSelection = NO;
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton && panel.URLs.count) {
        if (handler) {
            handler(YES,panel.URLs.firstObject);
        }
    }else{
        if (handler) {
            handler(NO,nil);
        }
    }
}
- (void)showErrorString:(NSString *)errorStr{
    NSLog(@"%@",errorStr);
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = errorStr;
    alert.alertStyle = NSAlertStyleWarning;
    [alert beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


@end
