#import "CaronaeTextField.h"
#import "ZoneSelectionInputViewController.h"

@interface ZoneSelectionInputViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *doneButton;
@property (weak, nonatomic) IBOutlet CaronaeTextField *neighborhoodTextField;

@end

@implementation ZoneSelectionInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.neighborhoodTextField becomeFirstResponder];
}


- (void)finishSelection {
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (self.neighborhoodSelectionType == NeighborhoodSelectionMany && [self.delegate respondsToSelector:@selector(hasSelectedNeighborhoods:inZone:)]) {
        [self.delegate hasSelectedNeighborhoods:@[self.neighborhoodTextField.text] inZone:@"Outros"];
    }
    else if (self.neighborhoodSelectionType == NeighborhoodSelectionOne && [self.delegate respondsToSelector:@selector(hasSelectedNeighborhood:inZone:)]) {
        [self.delegate hasSelectedNeighborhood:self.neighborhoodTextField.text inZone:@"Outros"];
    }
}

- (IBAction)didTapDoneButton:(id)sender {
    NSString *location = [self.neighborhoodTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (location > 0) {
        [self finishSelection];
    }
}

@end
