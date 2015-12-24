#import <AFNetworking/AFNetworking.h>
#import <ActionSheetStringPicker.h>
#import "FalaeViewController.h"

@interface FalaeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *typeButton;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (nonatomic) NSString *messagePlaceholder;
@property (nonatomic) UIColor *messageTextColor;
@property (nonatomic) NSString *selectedType;

@end

@implementation FalaeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _messageTextView.delegate = self;
    _messagePlaceholder = _messageTextView.text;
    _messageTextColor =  _messageTextView.textColor;
    _messageTextView.textColor = [UIColor lightGrayColor];
    
    if (!_selectedType) _selectedType = @"complaint";
}


#pragma mark - IBActions

- (IBAction)didTapSelectTypeButton:(id)sender {
    [self.view endEditing:YES];
    [ActionSheetStringPicker showPickerWithTitle:@"Qual o motivo do seu contato?"
                                            rows:@[@"Reclamação", @"Ajuda", @"Sugestão", @"Denúncia"]                                                           initialSelection:0
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
    NSString *message = _messageTextView.text;
    
    NSDictionary *params = @{@"type": type,
                             @"subject": subject,
                             @"message": message};
    
    NSLog(@"%@", params);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
