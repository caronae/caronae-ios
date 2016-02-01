#import "MessageBubbleTableViewCell.h"
#import "Message+CoreDataProperties.h"
#import "Caronae-Swift.h"

static const int incomingTag = 0;
static const int outgoingTag = 1;
static const int bubbleTag = 8;

static UIImage *bubbleImageIncoming;
static UIImage *bubbleImageOutgoing;

@implementation MessageBubbleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!bubbleImageIncoming) {
            UIImage *maskOutgoing = [UIImage imageNamed:@"MessageBubble"];
            UIImage *maskIncoming = [UIImage imageWithCGImage:maskOutgoing.CGImage scale:2 orientation:UIImageOrientationUpMirrored];
            
            UIEdgeInsets capInsetsIncoming = UIEdgeInsetsMake(17, 26.5, 17.5, 21);
            UIEdgeInsets capInsetsOutgoing = UIEdgeInsetsMake(17, 21, 17.5, 26.5);
            
            bubbleImageIncoming = [[maskIncoming imageWithRed:229.0/255.0 green:229.0/255.0 blue:235.0/255.0 alpha:1] resizableImageWithCapInsets:capInsetsIncoming];
            bubbleImageOutgoing = [[maskOutgoing imageWithRed:43.0/255.0 green:119.0/255.0 blue:250.0/255.0 alpha:1] resizableImageWithCapInsets:capInsetsOutgoing];
        }
        
        _bubbleImageView = [[UIImageView alloc] initWithImage:bubbleImageIncoming];
        _bubbleImageView.tag = bubbleTag;
        _bubbleImageView.userInteractionEnabled = NO;
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.font = [UIFont systemFontOfSize:17];
        _messageLabel.numberOfLines = 0;
        _messageLabel.userInteractionEnabled = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:_bubbleImageView];
        [_bubbleImageView addSubview:_messageLabel];
        
        _bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:4.5]];
        [_bubbleImageView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeWidth multiplier:1 constant:30]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-4.5]];
        
        [_bubbleImageView addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bubbleImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:3]];
        [_bubbleImageView addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bubbleImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:-0.5]];
        _messageLabel.preferredMaxLayoutWidth = 218;
        [_bubbleImageView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeHeight multiplier:1 constant:15]];
        
    }
    return self;
}

- (void)configureWithMessage:(Message *)message {
    _messageLabel.text = message.text;
    BOOL incoming = [message.incoming boolValue];
    
    if (incoming != (self.tag == incomingTag)) {
        NSLayoutAttribute layoutAttribute;
        CGFloat layoutConstant;
        
        if (incoming) {
            self.tag = incomingTag;
            _bubbleImageView.image = bubbleImageIncoming;
            _messageLabel.textColor = [UIColor blackColor];
            layoutAttribute = NSLayoutAttributeLeft;
            layoutConstant = 10;
        }
        else {
            self.tag = outgoingTag;
            _bubbleImageView.image = bubbleImageOutgoing;
            _messageLabel.textColor = [UIColor whiteColor];
            layoutAttribute = NSLayoutAttributeRight;
            layoutConstant = -10;
        }
        
        NSLayoutConstraint *layoutConstraint = _bubbleImageView.constraints[1]; // `messageLabel` CenterX
        layoutConstraint.constant = -layoutConstraint.constant;
        
        for (NSLayoutConstraint *constraint in self.contentView.constraints) {
            if (((UIView *)constraint.firstItem).tag == bubbleTag && (constraint.firstAttribute == NSLayoutAttributeLeft || constraint.firstAttribute == NSLayoutAttributeRight)) {
                [self.contentView removeConstraint:constraint];
                break;
            }
        }
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:layoutAttribute relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:layoutAttribute multiplier:1 constant:layoutConstant]];
    }
}

@end
