import UIKit
import Realm
import RealmSwift
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    var ride: Ride!
    var color: UIColor!
    var messages: Results<Message>!
    var messagesNotificationToken: RLMNotificationToken!
    
    convenience init(ride: Ride, color: UIColor) {
        self.init()
        self.ride = ride
        self.color = color
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
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: self.color)
        
        // Setting up avatars
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        self.loadChatMessages()
        self.clearNotifications()
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
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
        return String(messages[indexPath.item].sender.id) == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = messages[indexPath.item]
        //return getAvatar(message.senderId) //TODO: Get sender avatar image
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if String(message.sender.id) == self.senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        // Displaying names above messages
        
        /**
         *  Showing or removing senderDisplayName
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         */
        
        //Removing Sender Display Name
        if String(message.sender.id) == self.senderId {
            return nil
        }
        
        return NSAttributedString(string: message.sender.name)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         */
        
        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]
        
        if String(currentMessage.sender.id) == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.sender.id == currentMessage.sender.id {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
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

}
