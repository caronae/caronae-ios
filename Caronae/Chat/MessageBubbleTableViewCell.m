#import "MessageBubbleTableViewCell.h"
#import "Message+CoreDataProperties.h"
#import "Caronae-Swift.h"

static const int incomingTag = 0;
static const int outgoingTag = 1;
static const int bubbleTag = 8;

static NSDateFormatter *dateFormatter;

@implementation MessageBubbleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        }
        
        _bubbleView = [[UIView alloc] initWithFrame:CGRectZero];
        _bubbleView.tag = bubbleTag;
        _bubbleView.layer.cornerRadius = 8;
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.font = [UIFont systemFontOfSize:17];
        _messageLabel.numberOfLines = 0;
        
        _senderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _senderLabel.font = [UIFont systemFontOfSize:13];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.alpha = 0.5;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:_bubbleView];
        [_bubbleView addSubview:_senderLabel];
        [_bubbleView addSubview:_messageLabel];
        [_bubbleView addSubview:_timeLabel];
        
        _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:4.5]];
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeWidth multiplier:1 constant:20]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-4.5]];
        
        
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_senderLabel attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_senderLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bubbleView attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_senderLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_timeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_timeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bubbleView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_senderLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:4]];
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_timeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:5]];
        _messageLabel.preferredMaxLayoutWidth = 218;
        [_bubbleView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_timeLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:5]];
        
    }
    return self;
}

- (void)configureWithMessage:(Message *)message {
    _messageLabel.text = message.body;
    _senderLabel.text = message.sender.name;
    _timeLabel.text = [dateFormatter stringFromDate:message.date];
    
    NSLayoutAttribute layoutAttribute;
    CGFloat layoutConstant;
    
    if (message.incoming) {
        self.tag = incomingTag;
        _bubbleView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        _messageLabel.textColor = [UIColor darkTextColor];
        _senderLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.textColor = [UIColor lightGrayColor];
        layoutAttribute = NSLayoutAttributeLeft;
        layoutConstant = 10;
    }
    else {
        self.tag = outgoingTag;
        _bubbleView.backgroundColor = self.tintColor;
        _messageLabel.textColor = [UIColor whiteColor];
        _senderLabel.textColor = [UIColor lightTextColor];
        _timeLabel.textColor = [UIColor lightTextColor];
        layoutAttribute = NSLayoutAttributeRight;
        layoutConstant = -10;
    }
    
    for (NSLayoutConstraint *constraint in self.contentView.constraints) {
        if (((UIView *)constraint.firstItem).tag == bubbleTag && (constraint.firstAttribute == NSLayoutAttributeLeft || constraint.firstAttribute == NSLayoutAttributeRight)) {
            [self.contentView removeConstraint:constraint];
            break;
        }
    }
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleView attribute:layoutAttribute relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:layoutAttribute multiplier:1 constant:layoutConstant]];
    
}

@end
