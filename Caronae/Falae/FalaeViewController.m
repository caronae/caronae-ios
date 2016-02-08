#import <ActionSheetStringPicker.h>
#import <AFNetworking/AFNetworking.h>
#import <sys/utsname.h>
#import "CaronaeAlertController.h"
#import "FalaeViewController.h"

/**
 * Returns the model of the current device.
 */
NSString *deviceName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@interface FalaeViewController () <UITextViewDelegate>

@property (nonatomic) NSString *messagePlaceholder;
@property (nonatomic) UIColor *messageTextColor;
@property (nonatomic) NSString *selectedType;
@property (nonatomic) NSString *selectedTypeCute;
@property (nonatomic) int selectedTypeInitialIndex;
@property (nonatomic) NSArray *messageTypes;
@property (nonatomic) User *reportedUser;

@end

@implementation FalaeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _messageTypes = @[@"Reclamação", @"Ajuda", @"Sugestão", @"Denúncia"];
    
    _messageTextView.delegate = self;
    _messagePlaceholder = _messageTextView.text;
    _messageTextColor =  _messageTextView.textColor;
    _messageTextView.textColor = [UIColor lightGrayColor];
    
    if (_reportedUser) {
        _selectedType = @"report";
        _selectedTypeCute = @"Denúncia";
        _selectedTypeInitialIndex = 3;
        [_typeButton setTitle:@"Denúncia" forState:UIControlStateNormal];
        _subjectTextField.text = [NSString stringWithFormat:@"Denúncia sobre usuário %@ (id: %d)", _reportedUser.name, [_reportedUser.userID intValue]];
        _subjectTextField.enabled = NO;
    }
    else {
        _selectedTypeInitialIndex = 0;
        _selectedType = @"complaint";
        _selectedTypeCute = @"Reclamação";
    }
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    _loadingButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)setReport:(User *)user {
    _reportedUser = user;
}

- (void)sendMessage:(NSDictionary *)message {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[CaronaeDefaults defaults].userToken forHTTPHeaderField:@"token"];
    
    [self showLoadingHUD:YES];
    [manager POST:[CaronaeAPIBaseURL stringByAppendingString:@"/falae/sendMessage"] parameters:message success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showLoadingHUD:NO];
        
        [CaronaeAlertController presentOkAlertWithTitle:@"Mensagem enviada!" message:@"Obrigado por nos mandar uma mensagem. Nossa equipe irá entrar em contato em breve." handler:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
                                           if ([selectedValue isEqualToString:@"Reclamação"]) {
                                               _selectedType = @"complaint";
                                           }
                                           else if ([selectedValue isEqualToString:@"Sugestão"]) {
                                               _selectedType = @"suggestion";
                                           }
                                           else if ([selectedValue isEqualToString:@"Denúncia"]) {
                                               _selectedType = @"report";
                                           }
                                           else if ([selectedValue isEqualToString:@"Ajuda"]) {
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
    
    if ([_messageTextView.text isEqualToString:@""] || [_subjectTextField.text isEqualToString:@""]) {
        [CaronaeAlertController presentOkAlertWithTitle:@"" message:@"Por favor, preencha um assunto e uma mensagem para entrar em contato conosco."];
        return;
    }
    
    NSString *type = _selectedType;
    NSString *subject = [NSString stringWithFormat:@"[%@] %@", _selectedTypeCute, _subjectTextField.text];
    
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionBuildString = [NSString stringWithFormat:@"%@ (build %@)", appVersionString, appBuildString];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *device = deviceName();
    
    NSString *text = [NSString stringWithFormat:@"%@\n\n--------------------------------\nDevice: %@ (iOS %@)\nVersão do app: %@", _messageTextView.text, device, osVersion, versionBuildString];
    
    NSDictionary *message = @{@"type": type,
                             @"subject": subject,
                             @"message": text};
    
    [self sendMessage:message];
}


#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:_messagePlaceholder]) {
        textView.text = @"";
        textView.textColor = _messageTextColor;
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = _messagePlaceholder;
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}


#pragma mark - Etc

- (void)showLoadingHUD:(BOOL)loading {
    if (!loading) {
        self.navigationItem.rightBarButtonItem = self.sendButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.loadingButton;
    }
}

@end
