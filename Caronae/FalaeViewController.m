#import <AFNetworking/AFNetworking.h>
#import <ActionSheetStringPicker.h>
#import "CaronaeAlertController.h"
#import "FalaeViewController.h"

@interface FalaeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *typeButton;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic) UIBarButtonItem *loadingButton;
@property (nonatomic) NSString *messagePlaceholder;
@property (nonatomic) UIColor *messageTextColor;
@property (nonatomic) NSString *selectedType;
@property (nonatomic) int selectedTypeInitialIndex;
@property (nonatomic) NSArray *messageTypes;
@property (nonatomic) NSDictionary *reportedUser;
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
        _selectedTypeInitialIndex = 3;
        [_typeButton setTitle:@"Denúncia" forState:UIControlStateNormal];
        _subjectTextField.text = [NSString stringWithFormat:@"Denúncia sobre usuário %@ (id: %d)", _reportedUser[@"name"], [_reportedUser[@"id"] intValue]];
        _subjectTextField.enabled = NO;
    }
    else {
        _selectedTypeInitialIndex = 0;
        _selectedType = @"complaint";
    }
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    _loadingButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)setReport:(NSDictionary *)user {
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
    
    NSString *type = _selectedType;
    NSString *subject = _subjectTextField.text;
    NSString *text = _messageTextView.text;
    
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
