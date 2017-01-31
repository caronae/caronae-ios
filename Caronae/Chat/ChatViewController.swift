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
    var isSending = false
    
    var tappedMessageIndex: Int?
    
    convenience init(ride: Ride, color: UIColor) {
        self.init()
        self.ride = ride
        self.color = color
    }
    
    deinit {
        messagesNotificationToken.stop()
        NotificationCenter.default.removeObserver(self)
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
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: .jsq_messageBubbleLightGray())
        incomingBubbleTailless = JSQMessagesBubbleImageFactory(bubble: .jsq_bubbleCompactTailless(), capInsets: .zero).incomingMessagesBubbleImage(with: .jsq_messageBubbleLightGray())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: self.color)
        outgoingBubbleTailless = JSQMessagesBubbleImageFactory(bubble: .jsq_bubbleCompactTailless(), capInsets: .zero).outgoingMessagesBubbleImage(with: self.color)
        
        // Setting up avatars
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        self.loadChatMessages()
        self.clearNotifications()
        
        // Clear notifications when ApplicationWillEnterForeground
        NotificationCenter.default.addObserver(self, selector:#selector(self.clearNotifications), name: .UIApplicationWillEnterForeground, object: nil)
        
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
        if message.incoming {
            if shouldShowAvatar(atIndex: indexPath.item) {
                return incomingBubble
            } else {
                return incomingBubbleTailless
            }
        } else {
            if shouldShowAvatar(atIndex: indexPath.item) {
                return outgoingBubble
            } else {
                return outgoingBubbleTailless
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        guard shouldShowAvatar(atIndex: indexPath.item) else { return nil }
        
        let message = messages[indexPath.item]
        // Shows sender's image
        if let senderImageURL = message.sender.profilePictureURL, let requestUrl = URL(string:senderImageURL) {
            let senderImageView = UIImageView()
            senderImageView.crn_setImage(with: requestUrl)
            return JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: senderImageView.image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
        // Shows sender's initials
        let initials = message.sender.name.components(separatedBy: " ").prefix(3).reduce("") {$0 + String($1[$1.startIndex])}
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: .gray, textColor: .white, font: .systemFont(ofSize: 12), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        // Fix sender's name alignment, Fix text selection in messages and Change textColor
        cell.messageBubbleTopLabel.textInsets.left = CGFloat(50.0)
        cell.textView?.isSelectable = false
        cell.textView?.textColor = message.incoming ? .black : .white
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        // This logic should be consistent with the return from `heightForCellTopLabelAtIndexPath:`
        
        guard shouldShowTimestamp(atIndex: indexPath.item) else { return nil }
        let message = messages[indexPath.item]
        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        // This logic should be consistent with the return from `heightForMessageBubbleTopLabelAtIndexPath:`
        
        guard shouldShowSenderName(atIndex: indexPath.item) else { return nil }
        let message = messages[indexPath.item]
        return NSAttributedString(string: message.sender.name)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        // This logic should be consistent with the return from `attributedTextForCellTopLabelAtIndexPath:`
        
        guard shouldShowTimestamp(atIndex: indexPath.item) else { return 0.0 }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        // This logic should be consistent with the return from `attributedTextForCellTopLabelAtIndexPath:`
        
        guard shouldShowSenderName(atIndex: indexPath.item) else { return 0.0 }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        tappedMessageIndex = (tappedMessageIndex == indexPath.item) ? nil : indexPath.item
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // This logic should be consistent with the return from `heightForCellBottomLabelAtIndexPath:`
        
        // Shows the date of tapped message
        guard let index = tappedMessageIndex, index == indexPath.item else { return nil }
        
        let message = self.messages[index]
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return NSAttributedString(string: dateFormatter.string(from: message.date))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        // This logic should be consistent with the return from `attributedTextForCellBottomLabelAtIndexPath:`
        
        // Shows the date of tapped message
        guard let index = tappedMessageIndex, index == indexPath.item else { return 0.0 }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.inputToolbar.contentView?.rightBarButtonItem.isEnabled = false
        self.isSending = true
        self.inputToolbar.contentView?.textView.delegate = self
        ChatService.instance.sendMessage(text, rideID: ride.id) { message, error in
            self.isSending = false
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
        guard currentMessage.incoming else { return false }
        
        if index - 1 >= 0 {
            let previousMessage = self.messages[index - 1]
            if previousMessage.sender.id == currentMessage.sender.id && !shouldShowTimestamp(atIndex: index) {
                return false
            }
        }
        return true
    }
    
    
    // MARK: ChatService and Notification methods
    
    func loadChatMessages() {
        // Load local messages
        ChatService.instance.messagesForRide(withID: ride.id) { messages, error in
            guard error == nil else {
                NSLog("Whoops, couldn't load: %@", error!.localizedDescription)
                return
            }
            
            self.messages = messages
            self.subscribeToChanges()
        }
        
        // Check for updates
        ChatService.instance.updateMessagesForRide(withID: ride.id) { error in
            guard error == nil else {
                NSLog("Error updating messages for ride %ld. (%@)", self.ride.id, error!.localizedDescription)
                return
            }
            
            NSLog("Updated messages for ride %ld", self.ride.id)
        }
    }
    
    func subscribeToChanges() {
        messagesNotificationToken = messages.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.finishReceivingMessage()
        }
    }
    
    func clearNotifications() {
        NotificationService.instance.clearNotifications(forRideID: ride.id, of: .chat)
    }
    
    
    // MARK: UITextViewDelegate methods
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return !isSending
    }
    
}

