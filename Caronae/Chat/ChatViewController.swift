import Realm
import RealmSwift
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var incomingBubble: JSQMessagesBubbleImage!
    var incomingBubbleTailless: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var outgoingBubbleTailless: JSQMessagesBubbleImage!
    
    var ride: Ride!
    var color: UIColor!
    var messages: Results<Message>!
    var messagesNotificationToken: RLMNotificationToken!
    
    var tappedMessageIndex: Int?
    
    convenience init(ride: Ride, color: UIColor) {
        self.init()
        self.ride = ride
        self.color = color
    }
    
    deinit {
        messagesNotificationToken.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hidesBottomBarWhenPushed = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = " - dd/MM - HH:mm"
        self.title = ride.title + dateFormatter.string(from: ride.date)
        
        self.senderId = String(UserService.instance.user!.id)
        self.senderDisplayName = UserService.instance.user!.name
        
        // Setting up inputToolbar
        self.inputToolbar.contentView?.leftBarButtonItem = nil
        self.inputToolbar.contentView?.rightBarButtonItem.setTitleColor(self.color, for: .normal)
        self.inputToolbar.maximumHeight = 125
        
        // Setting up message bubble
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        incomingBubbleTailless = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: self.color)
        outgoingBubbleTailless = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: self.color)
        
        // Setting up avatars
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        self.loadChatMessages()
        self.clearNotifications()
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        self.scrollToBottom(animated: false)
    }
    
    
    // MARK: CollectionView DataSource (and related) methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        let message = messages[indexPath.item]
        return JSQMessage(senderId: String(message.sender.id), senderDisplayName: message.sender.name, date: message.date, text: message.body)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = messages[indexPath.item]
        if String(message.sender.id) == self.senderId {
            if shouldShowAvatar(atIndex: indexPath.item) {
                return outgoingBubble
            } else {
                return outgoingBubbleTailless
            }
        } else {
            if shouldShowAvatar(atIndex: indexPath.item) {
                return incomingBubble
            } else {
                return incomingBubbleTailless
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        if !shouldShowAvatar(atIndex: indexPath.item) {
            return nil
        }
        let message = messages[indexPath.item]
        // Shows sender's image
        if let senderImageURL = message.sender.profilePictureURL, let requestUrl = URL(string:senderImageURL) {
            let senderImageView = UIImageView()
            senderImageView.crn_setImage(with: requestUrl)
            return JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: senderImageView.image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
        // Shows sender's initials
        let initials = message.sender.name.components(separatedBy: " ").prefix(3).reduce("") {$0 + String($1[$1.startIndex])}
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: UIColor.gray, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        // Fix sender's name alignment and text selection in messages
        cell.messageBubbleTopLabel.textInsets.left = CGFloat(50.0)
        cell.textView?.isSelectable = false
        
        if String(message.sender.id) == self.senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        // This logic should be consistent with the return from `heightForCellTopLabelAtIndexPath:`
        
        if shouldShowTimestamp(atIndex: indexPath.item) {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        // This logic should be consistent with the return from `heightForMessageBubbleTopLabelAtIndexPath:`
        
        if shouldShowSenderName(atIndex: indexPath.item) {
            let message = messages[indexPath.item]
            return NSAttributedString(string: message.sender.name)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        // This logic should be consistent with the return from `attributedTextForCellTopLabelAtIndexPath:`
        
        if shouldShowTimestamp(atIndex: indexPath.item) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        // This logic should be consistent with the return from `attributedTextForCellTopLabelAtIndexPath:`
        
        if shouldShowSenderName(atIndex: indexPath.item) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if tappedMessageIndex == indexPath.item {
            tappedMessageIndex = nil
        } else {
            tappedMessageIndex = indexPath.item
        }
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // This logic should be consistent with the return from `heightForCellBottomLabelAtIndexPath:`
        
        // Shows the date of tapped message
        if let index = tappedMessageIndex, index == indexPath.item {
            let message = self.messages[indexPath.item]
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pt_BR")
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .medium
            return NSAttributedString(string: dateFormatter.string(from: message.date))
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        // This logic should be consistent with the return from `attributedTextForCellBottomLabelAtIndexPath:`
        
        // Shows the date of tapped message
        if let index = tappedMessageIndex, index == indexPath.item {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.inputToolbar.contentView?.rightBarButtonItem.isEnabled = false
        ChatService.instance.sendMessage(text, rideID: ride.id) { message, error in
            guard error == nil else {
                NSLog("Error sending message data: (%@)", error!.localizedDescription)
                CaronaeAlertController.presentOkAlert(withTitle: "Ops!", message: "Ocorreu um erro enviando sua mensagem.")
                self.inputToolbar.contentView?.rightBarButtonItem.isEnabled = true
                return
            }
            self.finishSendingMessage()
        }
    }
    
    
    // MARK: UI logic
    
    func shouldShowTimestamp (atIndex index: Int) -> Bool {
        let maxInterval = 3600.0 // 1 hour
        let currentMessage = self.messages[index]
        if index - 1 >= 0 {
            let previousMessage = self.messages[index - 1]
            if currentMessage.date.timeIntervalSince(previousMessage.date) < maxInterval {
                return false
            }
        }
        return true
    }
    
    func shouldShowAvatar (atIndex index: Int) -> Bool {
        let currentMessage = messages[index]
        if messages.indices.contains(index + 1) {
            let nextMessage = messages[index + 1]
            if currentMessage.sender.id == nextMessage.sender.id && !shouldShowTimestamp(atIndex: index + 1) {
                return false
            }
        }
        return true
    }
    
    func shouldShowSenderName (atIndex index: Int) -> Bool {
        let currentMessage = self.messages[index]
        if String(currentMessage.sender.id) == self.senderId {
            return false
        }
        if index - 1 >= 0 {
            let previousMessage = self.messages[index - 1]
            if previousMessage.sender.id == currentMessage.sender.id && !shouldShowTimestamp(atIndex: index) {
                return false
            }
        }
        return true
    }

}
