@import ActionSheetPicker_3_0;

#import <sys/utsname.h>
#import "CaronaeAlertController.h"
#import "FalaeViewController.h"
#import "Caronae-Swift.h"

/**
 * Returns the model of the current device.
 */
NSString *deviceName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@interface FalaeViewController ()

@property (nonatomic) NSString *selectedType;
@property (nonatomic) NSString *selectedTypeCute;
@property (nonatomic) int selectedTypeInitialIndex;
@property (nonatomic) NSArray *messageTypes;
@property (nonatomic) User *reportedUser;

@end

@implementation FalaeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _messageTypes = @[@"Sugestão", @"Denúncia", @"Dúvida"];
    
    if (_reportedUser) {
        _selectedType = @"report";
        _selectedTypeCute = @"Denúncia";
        _selectedTypeInitialIndex = (int)[_messageTypes indexOfObject:_selectedTypeCute];
        [_typeButton setTitle:@"Denúncia" forState:UIControlStateNormal];
        _subjectTextField.text = [NSString stringWithFormat:@"Denúncia sobre usuário %@ (id: %ld)", _reportedUser.name, (long)_reportedUser.id];
        _subjectTextField.enabled = NO;
    }
    else {
        _selectedType = @"complaint";
        _selectedTypeCute = @"Denúncia";
        _selectedTypeInitialIndex = (int)[_messageTypes indexOfObject:_selectedTypeCute];
    }
}

- (void)setReport:(User *)user {
    _reportedUser = user;
}

- (void)sendMessage:(NSDictionary *)message {
    
    [self showLoadingHUD:YES];
    [CaronaeAPIHTTPSessionManager.instance POST:@"/falae/sendMessage" parameters:message success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [self showLoadingHUD:NO];
        
        [CaronaeAlertController presentOkAlertWithTitle:@"Mensagem enviada!" message:@"Obrigado por nos mandar uma mensagem. Nossa equipe irá entrar em contato em breve." handler:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showLoadingHUD:NO];
        NSLog(@"Error: %@", error.localizedDescription);
        
        [CaronaeAlertController presentOkAlertWithTitle:@"Mensagem não enviada" message:@"Ocorreu um erro enviando sua mensagem. Verifique sua conexão e tente novamente."];
    }];
}

#pragma mark - IBActions

- (IBAction)didTapSelectTypeButton:(id)sender {
    [self.view endEditing:YES];
    [ActionSheetStringPicker showPickerWithTitle:@"Qual o motivo do seu contato?"
                                            rows:_messageTypes                                                          initialSelection:_selectedTypeInitialIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           _selectedTypeCute = selectedValue;
                                           if ([selectedValue isEqualToString:@"Sugestão"]) {
                                               _selectedType = @"suggestion";
                                           }
                                           else if ([selectedValue isEqualToString:@"Denúncia"]) {
                                               _selectedType = @"report";
                                           }
                                           else if ([selectedValue isEqualToString:@"Dúvida"]) {
                                               _selectedType = @"help";
                                           }
                                           else {
                                               _selectedType = @"other";
                                           }
                                           [_typeButton setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:nil origin:sender];
}

- (IBAction)didTapSendButton:(id)sender {
    [self.view endEditing:YES];
    
    NSString *messageText = [_messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (messageText.length == 0) {
        [CaronaeAlertController presentOkAlertWithTitle:@"Ops!" message:@"Parece que você esqueceu de preencher sua mensagem."];
        return;
    }
    
    NSString *type = _selectedType;
    NSString *subject = [NSString stringWithFormat:@"[%@] %@", _selectedTypeCute, _subjectTextField.text];
    
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionBuildString = [NSString stringWithFormat:@"%@ (build %@)", appVersionString, appBuildString];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *device = deviceName();
    
    NSString *text = [NSString stringWithFormat:@"%@\n\n--------------------------------\nDevice: %@ (iOS %@)\nVersão do app: %@", messageText, device, osVersion, versionBuildString];
    
    NSDictionary *message = @{@"type": type,
                              @"subject": subject,
                              @"message": text};
    
    [self sendMessage:message];
}


#pragma mark - Etc

- (void)showLoadingHUD:(BOOL)loading {
    self.navigationItem.rightBarButtonItem = loading ? self.loadingButton : self.sendButton;
}

- (UIBarButtonItem *)loadingButton {
    if (!_loadingButton) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        _loadingButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    }
    return _loadingButton;
}

@end
